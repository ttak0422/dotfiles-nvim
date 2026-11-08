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
let
  commandPreInit = ''
    local original_require = require
    local wrapped = false
    _G.pterm_test_calls = { setup = 0, list = 0, kills = {} }
    _G.require = function(name)
      local module = original_require(name)
      if name == "pterm" and not wrapped then
        wrapped = true
        local setup = module.setup
        module.setup = function(...)
          _G.pterm_test_calls.setup = _G.pterm_test_calls.setup + 1
          return setup(...)
        end
        -- Exercise the pinned plugin's real command/parser/completion. Only
        -- session side effects are spies; daemon behavior is tested separately.
        module.list = function()
          _G.pterm_test_calls.list = _G.pterm_test_calls.list + 1
          return { "fixture/dev", "fixture/test session" }
        end
        module.kill = function(name)
          table.insert(_G.pterm_test_calls.kills, name)
        end
      end
      return module
    end
  '';
in
{
  doc = ''
    # pterm

    ## 概要
    Neovim を再起動してもプロセスが存続する端末セッション。

    ## 主な機能
    - 常駐する PTY プロセスへ接続し、Neovim 標準端末で描画する。
    - 名前付き・階層型セッションと、任意の Telescope 検索に対応する。

    ## 使い方
    `:Pterm new dev` で開き、`:Pterm list` で一覧、`:Pterm redraw dev` で再描画する。`:Pterm kill dev` はセッションを終了する。Telescope 連携は `:Telescope pterm sessions` / `:Telescope pterm grep`。

    ## 要件
    Neovim 0.10 以上と flakes 有効の Nix。対応環境は x86_64 / aarch64 Linux と Apple Silicon macOS。管理接続には protocol version 2 が必要。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/pterm/blob/76663a45224c33f5b420485a6f1b92b96f2c3af7/README.md)
  '';

  lazy = true;
  # Current pterm uses list/kill subcommands, not the old PtermList/PtermKill.
  onCommands = [ "Pterm" ];
  onModules = [ "pterm" ];
  plugin = sources.pterm;
  config = luaConfig (
    # lua
    ''
      require("pterm").setup({})
    ''
  );
  extraPackages = with pkgs; [ pterm-daemon ];
  tests.pterm-command-lazy-routing = luaCheck {
    name = "pterm-command-lazy-routing";
    preInit = commandPreInit;
    script = ''
      local calls = _G.pterm_test_calls
      assert(not package.loaded.pterm and calls.setup == 0, "pterm must stay unloaded at startup")
      assert(not package.loaded.telescope, "Telescope must stay unloaded at startup")
      assert(vim.fn.exists(":Pterm") == 2, "the lazy Pterm command is missing")
      assert(vim.fn.exists(":PtermList") == 0 and vim.fn.exists(":PtermKill") == 0,
        "obsolete commands must not leave dead lazy stubs")
      vim.cmd("Pterm list")
      assert(calls.setup == 1 and calls.list == 1, "first command did not reach real Pterm list routing")
      assert(not package.loaded.telescope, "standalone Pterm must not load Telescope")
      local completion = vim.fn.getcompletion("Pterm ", "cmdline")
      for _, name in ipairs({ "new", "list", "redraw", "dump", "kill" }) do
        assert(vim.tbl_contains(completion, name), "missing subcommand completion: " .. name)
      end
      assert(vim.deep_equal(vim.fn.getcompletion("Pterm kill fixture/d", "cmdline"), { "fixture/dev" }),
        "session completion lost filtering or arguments")
      vim.cmd([[Pterm kill fixture/test\ session]])
      assert(vim.deep_equal(calls.kills, { "fixture/test session" }), "kill lost its escaped session argument")
      vim.cmd("Pterm kill")
      assert(#calls.kills == 1, "missing session must not reach kill")
      vim.cmd("Pterm list")
      assert(calls.setup == 1 and calls.list >= 3, "repeat commands must reuse setup and preserve list routing")
      assert(not package.loaded.telescope, "Pterm completions must not load Telescope")
    '';
  };
  tests.pterm-completion-lazy-routing = luaCheck {
    name = "pterm-completion-lazy-routing";
    preInit = commandPreInit;
    script = ''
      local calls = _G.pterm_test_calls
      assert(not package.loaded.pterm and calls.setup == 0, "pterm must stay unloaded at startup")
      local completion = vim.fn.getcompletion("Pterm ki", "cmdline")
      assert(vim.deep_equal(completion, { "kill" }), "first completion did not reach the real Pterm completer")
      assert(calls.setup == 1 and calls.list == 0, "subcommand completion must set up once without listing sessions")
      vim.cmd([[Pterm kill fixture/test\ session]])
      assert(vim.deep_equal(calls.kills, { "fixture/test session" }), "command after first completion lost arguments")
      vim.fn.getcompletion("Pterm ", "cmdline")
      assert(calls.setup == 1 and not package.loaded.telescope,
        "completion and commands must reuse setup without loading Telescope")
    '';
  };
}
