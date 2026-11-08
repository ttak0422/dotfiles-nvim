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
    # NeoZoom.lua

    ## 概要
    現在のウィンドウをフローティング表示に切り替え、作業対象に集中するためのプラグイン。

    ## 主な機能
    - タブ内のウィンドウ配置を保ったズーム。
    - filetype ごとのウィンドウ設定とコールバック。

    ## 使い方
    `require("neo-zoom").setup(...)` で表示を設定し、`:NeoZoomToggle` または `require("neo-zoom").neo_zoom()` で切り替える。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nyngwang/NeoZoom.lua/blob/c97a0197548c1e9b559e4fa41ab3f7782c93e613/README.md)
  '';
  lazy = true;
  onCommands = [ "NeoZoomToggle" ];
  onModules = [ "neo-zoom" ];
  plugin = sources.NeoZoom-lua;
  config = luaConfig (
    # lua
    ''
      require("neo-zoom").setup({
        winopts = { offset = { width = 180, height = 0.9 }, border = "single" },
        exclude_buftypes = {},
        presets = {
          {
            filetypes = { "dapui_.*", "dap-repl" },
            winopts = { offset = { top = 0.02, left = 0.26, width = 0.74, height = 0.6 } },
          },
        },
        callbacks = {
          function()
            vim.cmd("hi link NeoZoomFloatBg Normal")
            vim.cmd("hi link NeoZoomFloatBorder Normal")
            vim.cmd("set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder")
          end,
        },
      })
    '');
  tests.neozoom-command-lazy-roundtrip = luaCheck {
    name = "neozoom-command-lazy-roundtrip";
    ui = true;
    preInit = ''
      local original_require = require
      local wrapped = false
      _G.neozoom_test_setup_calls = 0
      _G.require = function(name)
        local module = original_require(name)
        if name == "neo-zoom" and not wrapped then
          wrapped = true
          local setup = module.setup
          module.setup = function(...)
            _G.neozoom_test_setup_calls = _G.neozoom_test_setup_calls + 1
            return setup(...)
          end
        end
        return module
      end
    '';
    script = ''
      local api = vim.api
      assert(not package.loaded["neo-zoom"] and _G.neozoom_test_setup_calls == 0,
        "NeoZoom must stay unloaded at startup")
      assert(vim.tbl_contains(vim.fn.getcompletion("NeoZoom", "command"), "NeoZoomToggle"),
        "the lazy command must be discoverable")
      assert(_G.neozoom_test_setup_calls == 0, "command-name completion must not load NeoZoom")
      vim.cmd.enew()
      api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "third" })
      vim.cmd.vsplit()
      local original_win, original_buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
      api.nvim_win_set_cursor(0, { 2, 3 })
      local original_wins, layout = api.nvim_tabpage_list_wins(0), vim.fn.winlayout()
      local function roundtrip()
        vim.cmd.NeoZoomToggle()
        local zoom = require("neo-zoom")
        local zoom_win = api.nvim_get_current_win()
        assert(zoom.did_zoom()[1] and zoom.is_neo_zoom_float(), "command did not create a real zoom window")
        assert(zoom_win ~= original_win and zoom.zoom_book[zoom_win] == original_win,
          "zoom lost its original window")
        assert(api.nvim_win_get_buf(zoom_win) == original_buf, "zoom must display the original buffer")
        assert(api.nvim_win_get_config(zoom_win).relative == "editor", "zoom is not a floating window")
        assert(vim.wo[zoom_win].winhl:find("Normal:NeoZoomFloatBg", 1, true),
          "the configured zoom callback did not run")
        vim.cmd.NeoZoomToggle()
        assert(not api.nvim_win_is_valid(zoom_win) and not zoom.did_zoom()[1], "toggle did not close zoom")
        assert(api.nvim_get_current_win() == original_win and api.nvim_get_current_buf() == original_buf,
          "toggle did not restore the original window and buffer")
        assert(vim.deep_equal(api.nvim_win_get_cursor(0), { 2, 3 }), "toggle did not restore the cursor")
        assert(vim.deep_equal(api.nvim_tabpage_list_wins(0), original_wins)
          and vim.deep_equal(vim.fn.winlayout(), layout), "toggle changed the original split layout")
      end
      roundtrip()
      roundtrip()
      assert(_G.neozoom_test_setup_calls == 1, "repeated commands must not repeat NeoZoom setup")
    '';
  };
}
