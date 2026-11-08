{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  doc = ''
    # capture.vim

    ## 概要
    Ex コマンドの出力をバッファに表示する。

    ## 主な機能
    - メッセージ、マッピング、読み込み済みスクリプトを検索可能なバッファに取り込む。
    - 外部コマンドの出力も取り込む。

    ## 使い方
    `:Capture mes`、`:Capture scriptnames`、`:Capture map | map! | lmap` を実行する。外部コマンドには `:Capture !ls` を使える。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/tyru/capture.vim/blob/857ee11cfe1193948d3d45dcb8d511fded8533fb/README.md)
  '';

  plugin = sources.capture-vim;
  lazy = true;
  onCommands = [ "Capture" ];
  tests.capture-command-lazy-replay = luaCheck {
    name = "capture-command-lazy-replay";
    script = ''
      local api = vim.api
      assert(vim.g.loaded_capture == nil, "Capture must stay unloaded before its first command")
      vim.cmd.enew()
      local source = api.nvim_get_current_buf()
      api.nvim_buf_set_lines(source, 0, -1, false, { "source unchanged" })
      local windows = #api.nvim_tabpage_list_wins(0)

      -- Capture accepts a bang and raw Ex arguments, but does not accept a range.
      local first = [=[echo "quoted spaces: \"yes\" \\ tail" | echo 'pipe | value']=]
      vim.cmd("Capture! " .. first)
      local captured = api.nvim_get_current_buf()
      assert(vim.g.loaded_capture == 1, "the first command did not load Capture")
      assert(captured ~= source and #api.nvim_tabpage_list_wins(0) == windows + 1,
        "Capture! must open a new output buffer and window")
      assert(vim.bo[captured].filetype == "capture" and vim.bo[captured].buftype == "nofile"
        and vim.bo[captured].bufhidden == "unload" and not vim.bo[captured].buflisted
        and not vim.bo[captured].swapfile, "the capture buffer options were not applied")
      local initial = { [=[quoted spaces: "yes" \ tail]=], "pipe | value" }
      assert(vim.deep_equal(api.nvim_buf_get_lines(captured, 0, -1, false), initial),
        "cold command replay changed quoted, escaped or piped Ex arguments")
      assert(vim.deep_equal(vim.b[captured].capture_commands, { first }),
        "Capture did not receive the original raw arguments")

      local second = "echo 'second value with spaces'"
      vim.cmd("Capture " .. second)
      assert(api.nvim_get_current_buf() == captured and #api.nvim_tabpage_list_wins(0) == windows + 1,
        "plain Capture must reuse its existing output window")
      local appended = {
        first .. ":", initial[1], initial[2], "", second .. ":", "second value with spaces",
      }
      assert(vim.deep_equal(api.nvim_buf_get_lines(captured, 0, -1, false), appended),
        "repeated Capture did not append the output and command headings")
      assert(vim.deep_equal(vim.b[captured].capture_commands, { first, second }),
        "repeated Capture did not retain its command history")

      local third = "echo 'separate output'"
      vim.cmd("Capture! " .. third)
      local separate = api.nvim_get_current_buf()
      assert(separate ~= captured and separate ~= source
        and #api.nvim_tabpage_list_wins(0) == windows + 2, "Capture! must bypass the existing output buffer")
      assert(vim.deep_equal(api.nvim_buf_get_lines(separate, 0, -1, false), { "separate output" })
        and vim.deep_equal(vim.b[separate].capture_commands, { third }), "new capture output is incorrect")
      assert(vim.deep_equal(api.nvim_buf_get_lines(captured, 0, -1, false), appended),
        "Capture! changed the previous capture buffer")
      assert(vim.deep_equal(api.nvim_buf_get_lines(source, 0, -1, false), { "source unchanged" }),
        "capturing output modified the source buffer")
      assert(vim.v.errmsg == "", vim.v.errmsg)
    '';
  };
  # A separate process keeps completion as the first load entrypoint.
  tests.capture-command-lazy-completion = luaCheck {
    name = "capture-command-lazy-completion";
    script = ''
      local api = vim.api
      assert(vim.g.loaded_capture == nil, "Capture must stay unloaded before completion")
      local buffer, windows = api.nvim_get_current_buf(), #api.nvim_tabpage_list_wins(0)
      assert(vim.tbl_contains(vim.fn.getcompletion("Capt", "command"), "Capture"),
        "the lazy Capture command must be discoverable")
      assert(vim.g.loaded_capture == nil, "command-name completion must not load Capture")
      assert(vim.tbl_contains(vim.fn.getcompletion("Capture ec", "cmdline"), "echo"),
        "first argument completion must use Capture's command completion")
      assert(vim.g.loaded_capture == 1, "argument completion did not load Capture")
      assert(api.nvim_get_current_buf() == buffer and #api.nvim_tabpage_list_wins(0) == windows,
        "completion must not execute Capture or create an output window")
      vim.cmd([[Capture echo "completion-first"]])
      assert(vim.bo.filetype == "capture"
        and vim.deep_equal(api.nvim_buf_get_lines(0, 0, -1, false), { "completion-first" }),
        "Capture did not execute correctly after first-use completion")
      assert(vim.v.errmsg == "", vim.v.errmsg)
    '';
  };
}
