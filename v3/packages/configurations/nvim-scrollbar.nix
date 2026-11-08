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
    # nvim-scrollbar

    ## 概要
    診断や Git 変更などの位置を示す拡張可能なスクロールバー。

    ## 主な機能
    - スクロール位置、診断、任意の検索・Git マークを表示する。
    - ハンドルやマークの見た目と更新頻度を設定できる。

    ## 使い方
    `require("scrollbar").setup()` で初期化する。この定義は Git ハンドラーを有効、カーソルマークを無効にしている。`:ScrollbarToggle` で表示を切り替える。README の検索連携は別途設定する任意機能。

    ## 要件
    Neovim 0.5.1 以上。Git 連携には gitsigns.nvim、検索連携には nvim-hlslens が必要。既存の設定 API を維持するため、更新が終了した上流の `v1` ブランチを参照し、`main` の v2 移行とは独立させている。

    ## 出典
    - [固定バージョンの README](https://github.com/petertriho/nvim-scrollbar/blob/f8e87b96cd6362ef8579be456afee3b38fd7e2a8/README.md)
    - [上流の v1 継続案内](https://github.com/petertriho/nvim-scrollbar/issues/121)
  '';

  plugin = sources.nvim-scrollbar;
  dependPlugins = [
    definitions.gitsigns-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("scrollbar").setup({
        throttle_ms = 250,
        handle = { blend = 0 },
        handlers = { gitsigns = true, cursor = false },
      })
    ''
  );

  tests.scrollbar-git-and-diagnostics = luaCheck {
    name = "scrollbar-git-and-diagnostics";
    ui = true;
    script = ''
      local api = vim.api
      local scrollbar = require("scrollbar")
      local config = require("scrollbar.config").get()
      assert(config.throttle_ms == 250 and config.handle.blend == 0,
        "the profile must retain its v1 appearance and update settings")
      assert(config.handlers.gitsigns and config.handlers.diagnostic and not config.handlers.cursor,
        "the profile must retain Git and diagnostic handlers without cursor marks")
      local root = vim.fn.tempname()
      vim.fn.mkdir(root, "p")
      local function git(...)
        local command = { "${pkgs.git}/bin/git", "-C", root }
        vim.list_extend(command, { ... })
        local result = vim.system(command, { text = true }):wait()
        assert(result.code == 0, result.stderr)
      end
      git("init", "--quiet")
      local lines = {}
      for index = 1, 200 do lines[index] = "line " .. index end
      local file = root .. "/scrollbar-fixture.txt"
      vim.fn.writefile(lines, file)
      git("add", "scrollbar-fixture.txt")
      git("-c", "user.name=Scrollbar Test", "-c", "user.email=test@example.invalid",
        "-c", "commit.gpgsign=false", "commit", "--quiet", "-m", "fixture")
      lines[50] = "changed line 50"
      vim.fn.writefile(lines, file)
      vim.cmd.edit(vim.fn.fnameescape(file))
      local buf = api.nvim_get_current_buf()
      local function has_mark(mark_type, line)
        for _, marks in pairs(require("scrollbar.utils").get_scrollbar_marks(buf)) do
          for _, mark in ipairs(marks) do
            if mark.type == mark_type and mark.line == line then return true end
          end
        end
        return false
      end
      assert(vim.wait(5000, function() return has_mark("GitChange", 49) end, 20),
        "the real GitSignsUpdate event did not publish a GitChange mark")
      assert(#(require("gitsigns").get_hunks(buf) or {}) > 0, "the fixture must have real Git hunks")
      local diagnostic_ns = api.nvim_create_namespace("scrollbar-test-diagnostics")
      vim.diagnostic.set(diagnostic_ns, buf, {
        { lnum = 79, col = 0, message = "fixture", severity = vim.diagnostic.severity.ERROR },
      })
      assert(vim.wait(1000, function() return has_mark("Error", 79) end, 20),
        "the real diagnostic handler did not publish an Error mark")
      local scrollbar_ns = api.nvim_get_namespaces()[require("scrollbar.const").NAME_PREFIX]
      local function extmarks()
        return api.nvim_buf_get_extmarks(buf, scrollbar_ns, 0, -1, {})
      end
      scrollbar.render()
      assert(#extmarks() > 0, "the scrollbar must render its marks")
      for _ = 1, 2 do
        vim.cmd.ScrollbarToggle()
        assert(not config.show and #extmarks() == 0, "toggle must hide the scrollbar")
        vim.cmd.ScrollbarToggle()
        assert(config.show and #extmarks() > 0, "toggle must restore the scrollbar")
      end
    '';
  };
}
