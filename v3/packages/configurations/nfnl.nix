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
    # nfnl

    ## 概要
    Fennel を保存時に Lua へコンパイルし、Neovim 設定やプラグインを開発するためのツール。

    ## 主な機能
    - `.nfnl.fnl` のあるプロジェクトで自動起動。
    - コンパイルエラーの通知と既存 Lua の上書き保護。

    ## 使い方
    プロジェクトのルートに `.nfnl.fnl` を置き、Fennel ファイルを保存する。最初に設定ファイルを信頼するか確認される。`:NfnlFile` は対応する生成済み Lua を実行する。

    ## 要件
    Neovim 0.9.0 以上。Fennel バッファの ftplugin で起動し、手動 require や遅延読込設定は不要。

    ## 出典
    [固定リビジョンの README](https://github.com/Olical/nfnl/blob/7a4ba217167fee57e9bf175405636ced49aa9f83/README.md)
  '';
  lazy = true;
  onCommands = [ "NfnlCompileAllFiles" ];
  onFiletypes = [ "fennel" ];
  onModules = [ "nfnl" ];
  # Upstream creates this command only in Fennel buffers. Keep the old global
  # command entry point useful when invoked before the first Fennel buffer.
  config = ''
    vim.api.nvim_create_user_command("NfnlCompileAllFiles", function(opts)
      require("nfnl.api")["compile-all-files"](opts.fargs[1])
    end, { nargs = "?", complete = "file", desc = "Compile the project's Fennel files" })
  '';
  plugin = sources.nfnl;
  dependPlugins = [
    definitions.conjure
  ];
  extraPackages = with pkgs; [
    sd
    fd
  ];
  tests.nfnl-command-lazy-compile = luaCheck {
    name = "nfnl-command-lazy-compile";
    preInit = ''
      local create = vim.api.nvim_create_user_command
      _G.nfnl_test_config_calls = 0
      vim.api.nvim_create_user_command = function(name, callback, opts)
        if name == "NfnlCompileAllFiles" and opts.desc == "Compile the project's Fennel files" then
          _G.nfnl_test_config_calls = _G.nfnl_test_config_calls + 1
        end
        return create(name, callback, opts)
      end
    '';
    script = ''
      assert(not package.loaded["nfnl.api"] and not package.loaded["nfnl.callback"]
        and _G.nfnl_test_config_calls == 0, "nfnl must stay unloaded at startup")
      assert(vim.fn.exists(":NfnlCompileAllFiles") == 2, "the lazy compile command is missing")
      assert(not vim.api.nvim_buf_get_commands(0, {}).NfnlCompileAllFiles,
        "the first compile must use the global entry point, not a Fennel ftplugin")
      local root = vim.env.HOME .. "/nfnl command fixture"
      vim.fn.mkdir(root .. "/fnl", "p")
      local config, source, output = root .. "/.nfnl.fnl", root .. "/fnl/answer.fnl", root .. "/lua/answer.lua"
      vim.fn.writefile({ "{}" }, config)
      vim.fn.writefile({ "(set _G.nfnl_test_answer 42)", "{:answer _G.nfnl_test_answer}" }, source)
      -- Only trust this test-owned fixture in luaCheck's isolated XDG state.
      assert(vim.startswith(vim.fn.stdpath("state"), vim.env.XDG_STATE_HOME .. "/"))
      local trusted, reason = vim.secure.trust({ action = "allow", path = config })
      assert(trusted, reason)
      vim.cmd("NfnlCompileAllFiles " .. vim.fn.fnameescape(root))
      assert(_G.nfnl_test_config_calls == 1 and package.loaded["nfnl.api"],
        "first command did not load and configure the real compiler")
      assert(vim.fn.filereadable(output) == 1 and dofile(output).answer == 42,
        "first command lost its directory argument or failed to compile Fennel")
      local command = vim.api.nvim_get_commands({}).NfnlCompileAllFiles
      assert(command.nargs == "?" and command.complete == "file", "global command options changed")
      local completion = vim.fn.getcompletion("NfnlCompileAllFiles " .. vim.fn.fnameescape(root .. "/fnl/ans"), "cmdline")
      assert(#completion > 0, "loaded compile command lost file completion")

      vim.fn.writefile({ "(set _G.nfnl_test_answer 43)", "{:answer _G.nfnl_test_answer}" }, source)
      vim.cmd("NfnlCompileAllFiles " .. vim.fn.fnameescape(root))
      assert(dofile(output).answer == 43, "repeated global compile did not update real output")
      vim.cmd("edit " .. vim.fn.fnameescape(source))
      assert(vim.bo.filetype == "fennel", "fixture did not open as Fennel")
      local commands = vim.api.nvim_buf_get_commands(0, {})
      for _, name in ipairs({ "NfnlCompileAllFiles", "NfnlCompileFile", "NfnlFile", "NfnlFindOrphans", "NfnlDeleteOrphans" }) do
        assert(commands[name], "upstream buffer-local command is missing: " .. name)
      end
      assert(commands.NfnlCompileAllFiles.definition:find("nfnl.api/compile-all-files", 1, true),
        "the upstream buffer-local compile command was replaced")
      vim.api.nvim_buf_set_lines(0, 0, -1, false,
        { "(set _G.nfnl_test_answer 44)", "{:answer _G.nfnl_test_answer}" })
      vim.cmd.write()
      assert(dofile(output).answer == 44, "Fennel BufWritePost did not compile with the real ftplugin")
      _G.nfnl_test_answer = nil
      vim.cmd.NfnlFile()
      assert(_G.nfnl_test_answer == 44, "upstream NfnlFile did not execute compiled Lua")
      vim.cmd("NfnlCompileAllFiles " .. vim.fn.fnameescape(root))
      assert(_G.nfnl_test_config_calls == 1, "Fennel filetype or repeated command reran global config")
      vim.cmd.enew()
      assert(not vim.api.nvim_buf_get_commands(0, {}).NfnlCompileAllFiles,
        "upstream compile command leaked into another buffer")
      assert(vim.api.nvim_get_commands({}).NfnlCompileAllFiles.complete == "file",
        "the global wrapper disappeared after visiting a Fennel buffer")
    '';
  };
}
