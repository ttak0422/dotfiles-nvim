{ pkgs, sources }:
let
  goda = pkgs.vimUtils.buildVimPlugin {
    pname = "goda.vim";
    version = sources."goda.vim".version;
    src = sources."goda.vim";
  };
  skk = pkgs.vimUtils.buildVimPlugin {
    pname = "goda-skk.vim";
    version = sources."goda-skk.vim".version;
    src = sources."goda-skk.vim";

  };
  binary = pkgs.buildGoModule {
    pname = "goda-skk";
    version = sources."goda-skk.vim".version;
    src = ./config;
    subPackages = [ "." ];
    # Editor scripts and compiled Go use the same unmodified upstream pins.
    postPatch = ''
      mkdir -p .deps
      cp -R ${sources."goda.vim"} .deps/goda
      cp -R ${sources."goda-skk.vim"} .deps/goda-skk
      cat >> go.mod <<EOF
      replace github.com/Shougo/goda.vim => ./.deps/goda
      replace github.com/Shougo/goda-skk.vim => ./.deps/goda-skk
      EOF
    '';
    vendorHash = "sha256-02nf8GIV8+9SRdWuutdbRrhx1d4DEVH1RiuUwP/Ovto=";
    env.CGO_ENABLED = "0";
    ldflags = [
      "-s"
      "-w"
      "-X main.dictionary=${pkgs.skk-dict}/SKK-JISYO.L"
    ];
    meta.mainProgram = "goda-skk";
  };
in
{
  plugin = skk;
  dependPlugins = [ goda ];
  config = # lua
    ''
      vim.env.GODA_SKK_STATE_DIR = vim.fn.stdpath("state") .. "/goda-skk"
      vim.g["goda_skk#binary"] = "${binary}/bin/goda-skk"
      vim.keymap.set({ "i", "c", "t" }, "<C-j>", "<Plug>(goda-skk-enable)", {
        silent = true, desc = "Enable Goda SKK",
      })
    '';
  doc = ''
    Goda SKK uses Shougo/goda.vim v0.7.2 and goda-skk.vim v0.3.3, pinned
    in v3/npins. The same sources feed Vim scripts and Go module replacements.
    This cartridge can be included in any divine configuration; v3/default
    includes it and is the only v3 package exported by the flake.
    Run `nix run .#v3/default`. Build/check it with `nix flake check`.

    The editor scripts load at startup with an explicit Goda dependency.
    The prebuilt Go process starts only on the first enabled key, including
    command-line or terminal first use. No InsertEnter trigger is required.
    Upstream requires Go >= 1.26 for builds and Neovim >= 0.11.

    <C-j> enables SKK in insert, command-line and terminal modes; jk escapes.
    EggLikeNewline confirms a conversion with Enter without adding a line.
    The existing pinned SKK-JISYO.L is decoded as EUC-JP, available offline.
    Learning is UTF-8 in stdpath("state")/goda-skk/SKK-JISYO.user, isolated
    by the v3/default wrapper's NVIM_APPNAME=nvim-v3-default. Existing v2
    skkeleton data is untouched. No runtime Go/Deno, startup downloads,
    external SKK server or Google API is needed. Do not call goda_skk#build():
    rebuild the Nix package after changing the owned Go configuration.

    Upstream v0.3.3 writes the learned dictionary without a cross-process lock
    and with a shared temporary filename. Concurrent editors sharing that
    state can lose entries or fail a write. Use one learning session or
    separate XDG state roots until upstream fixes this limitation.

    Update plugin sources with `npins -d v3/npins update`, review the release
    and API changes, and align config/go.mod and config/go.sum. Pin a specific
    release with `npins -d v3/npins add github Shougo goda.vim --at v0.7.2`
    (likewise goda-skk.vim). npins owns plugin locks; flake.lock owns divine
    and the environment. The dictionary is reused rather than pinned twice.
    When source dependencies change, temporarily set vendorHash to
    pkgs.lib.fakeHash and build .#v3/default to refresh it, even if an old
    vendor output is cached. Both lock layers and vendorHash are required.

    The inline Nix check uses Python/pynvim and real RPC input, temporary
    HOME/XDG directories and restarts. Go/Deno may be on PATH for other
    migrated language tools; SKK itself always uses the fixed prebuilt binary. It covers kana,
    EUC-JP conversion, candidate cycling/confirmation, learning persistence,
    jk, command-line first use, and terminal first use. These tools remain
    check-only dependencies. Linux evaluation is not Linux runtime validation.
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
            assert nvim.eval("exists('g:loaded_skkeleton')") == 0
            for mode in ["i", "c", "t"]:
                assert "goda-skk-enable" in nvim.call("maparg", "<C-j>", mode)
            # The full editor also carries Go/Deno language servers; SKK uses its fixed binary.
            assert nvim.call("exists", "g:loaded_denops") == 0
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
    assert pkgs.lib.any (node: node.package == skk && builtins.elem (toString goda) node.dependencies) (
      builtins.attrValues bundle.graph.nodes
    );
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
