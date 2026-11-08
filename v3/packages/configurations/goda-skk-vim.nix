{
  pkgs,
  sources,
  definitions,
}:
let
  binary = sources.goda-skk;
in
{
  plugin = sources.goda-skk-vim;
  dependPlugins = [ definitions.goda-vim ];
  extraPackages = [ binary ];
  config = # lua
    ''
      vim.env.GODA_SKK_STATE_DIR = vim.fn.stdpath("state") .. "/goda-skk"
      vim.g["goda_skk#binary"] = "${binary}/bin/goda-skk"
      vim.keymap.set({ "i", "c", "t" }, "<C-j>", "<Plug>(goda-skk-enable)", {
        silent = true, desc = "Enable Goda SKK",
      })
    '';
  doc = ''
    # goda-skk.vim

    ## 概要
    Goで実装・設定するVim/Neovim向けSKK日本語入力。goda.vimを基盤とし、
    skkeletonと同じ入力方式を引き継ぐ初期段階のプロジェクトです。

    ## 主な機能
    - 送り仮名付き変換、単語登録、ユーザー辞書、変換取消に対応します。
    - 挿入モード、コマンドライン、端末で入力でき、変換前表示と状態popupを内蔵します。
    - goda-cmp補完、SKKサーバー、Google日本語入力の辞書は上流の任意連携です。

    ## 使い方
    Goの設定プログラムへ辞書を登録し、`<Plug>(goda-skk-enable)`へキーを割り当てます。
    READMEの例では挿入モードで`<C-j>`、`Kanji<Space>`と入力して変換し、
    `<C-j>`で確定します。診断は`:echo goda#log()`、詳細は`:help goda_skk`で確認できます。
    READMEは設定変更後の再ビルドと、`go test ./...`によるテストを案内しています。

    ## 要件
    goda.vim、SKK辞書、ビルド用Go 1.26以上が必要です。エディタはNeovim 0.11以上、
    または`+job +channel +popupwin`付きVim 9.1以上です。

    ## 出典
    [goda-skk.vim README（v0.3.3の固定revision）](https://github.com/Shougo/goda-skk.vim/blob/b138f25d97610f8dc5cd644fc05797728ecf62f4/README.md)
  '';
  tests.skk-input =
    {
      pkgs,
      bundle,
      neovim,
    }:
    let
      python = pkgs.python3.withPackages (ps: [ ps.pynvim ]);
      script = pkgs.writeText "skk-input.py" ''
        """Exercise real Neovim input and the packaged Go backend, with isolated XDG dirs."""
        import os
        import pathlib
        import sys
        import time

        import pynvim


        def wait(nvim, predicate, label):
            end = time.monotonic() + 10
            while time.monotonic() < end:
                if predicate():
                    return
                time.sleep(0.02)
            raise AssertionError(f"{label}: mode={nvim.eval('mode()')}, lines={nvim.current.buffer[:]}, log={nvim.call('goda#log')}")


        def send(nvim, keys):
            nvim.input(keys)
            # Round trip, rather than fixed sleep, followed by explicit state assertions.
            nvim.eval("1")


        def start():
            nvim = pynvim.attach("child", argv=[sys.argv[1], "--embed", "--headless", "-n", "-i", "NONE"])
            assert nvim.exec_lua("return package.loaded.divine ~= nil")
            assert nvim.exec_lua("return vim.tbl_contains(vim.v.argv, vim.env.SKK_TEST_BUNDLE .. '/init.lua')")
            assert nvim.eval("v:errmsg") == ""
            assert nvim.eval("executable(g:['goda_skk#binary'])") == 1
            assert nvim.eval("exists('g:loaded_goda_skk')") == 1
            for mode in ["i", "c", "t"]:
                assert "goda-skk-enable" in nvim.call("maparg", "<C-j>", mode)
            return nvim


        def stop(nvim):
            try:
                nvim.command("qa!")
            except EOFError:
                pass
            finally:
                nvim.close()


        # Each mode is the first SKK use in a new editor, not masked by InsertEnter.
        nvim = start()
        try:
            send(nvim, "i<C-j>aiueo")
            wait(nvim, lambda: nvim.current.line == "あいうえお", "hiragana input")
            send(nvim, "<Esc>")
            wait(nvim, lambda: nvim.eval("mode()") == "n", "leave insert mode")
            assert not nvim.call("goda_skk#is_enabled")
            nvim.current.buffer[:] = [""]
            send(nvim, "i<C-j>Kanji<Space>")
            wait(nvim, lambda: nvim.current.line.startswith("▼") and len(nvim.current.line) > 1, "EUC-JP dictionary conversion")
            first = nvim.current.line
            send(nvim, "<Space>")
            wait(nvim, lambda: nvim.current.line != first, "next candidate")
            selected = nvim.current.line.removeprefix("▼")
            assert any("\u4e00" <= char <= "\u9fff" for char in selected), selected
            send(nvim, "<C-j><Esc>")
            wait(nvim, lambda: nvim.current.line == selected and nvim.eval("mode()") == "n", "confirm conversion")
            user_dict = pathlib.Path(nvim.eval("$GODA_SKK_STATE_DIR")) / "SKK-JISYO.user"
            wait(nvim, lambda: user_dict.exists() and selected in user_dict.read_text(), "persist learned candidate")
            assert str(user_dict).startswith(os.environ["XDG_STATE_HOME"])
            nvim.current.buffer[:] = [""]
            send(nvim, "i<C-j>aiujk")
            wait(nvim, lambda: nvim.current.line == "あいう" and nvim.eval("mode()") == "n", "jk escape rule")
            assert not nvim.call("goda_skk#is_enabled")
        finally:
            stop(nvim)

        nvim = start()
        try:
            send(nvim, "/<C-j>aiueo")
            wait(nvim, lambda: nvim.call("getcmdline") == "あいうえお", "command-line first use")
            send(nvim, "<Esc>")
            wait(nvim, lambda: nvim.eval("mode()") == "n", "leave command line")
            send(nvim, "i<C-j>Kanji<Space>")
            wait(nvim, lambda: nvim.current.line == "▼" + selected, "reload learned candidate")
            send(nvim, "<C-g><Esc>")
        finally:
            stop(nvim)

        nvim = start()
        try:
            nvim.command("terminal " + os.environ["SKK_TEST_CAT"])
            send(nvim, "i<C-j>aiueo")
            wait(nvim, lambda: "あいうえお" in "\n".join(nvim.current.buffer[:]), "terminal first use")
            send(nvim, "<C-\\><C-n>")
            wait(nvim, lambda: nvim.eval("mode()") == "n", "leave terminal")
            assert not nvim.call("goda_skk#is_enabled")
        finally:
            stop(nvim)

        print("Goda SKK: insert, conversion, cycling, learning/restart, jk, command-line and terminal passed")
      '';
    in
    pkgs.runCommand "skk-input" { } ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$TMPDIR/config" XDG_DATA_HOME="$TMPDIR/data"
      export XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache"
      export SKK_TEST_CAT=${pkgs.coreutils}/bin/cat
      export SKK_TEST_BUNDLE=${bundle}
      mkdir -p "$HOME"
      ${python}/bin/python ${script} ${neovim}/bin/nvim
      touch "$out"
    '';
}
