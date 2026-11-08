{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
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

  plugin = sources.pterm;
  dependPlugins = [
    definitions.telescope-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local pterm = require("pterm")
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local parser = require("telescope-live-grep-args.prompt_parser")

      -- Telescope is configured by the dependency before registering this extension.
      pterm.setup({})
      telescope.load_extension("pterm")

      local function create_session(prompt_bufnr)
        local prompt = vim.trim(action_state.get_current_line())
        local names = pterm.list()
        -- Preserve existing names containing spaces instead of parsing them as commands.
        local argv = vim.tbl_contains(names, prompt) and { prompt } or parser.parse(prompt, false)
        local name, command = argv[1], argv[2]
        if not name or name == "" then
          actions.close(prompt_bufnr)
          return
        end
        if command and vim.tbl_contains(names, name) then
          vim.notify("Session '" .. name .. "' already exists; select it without a command", vim.log.levels.ERROR)
          return
        end
        if command and vim.fn.executable(command) == 0 then
          vim.notify("Executable not found: " .. command, vim.log.levels.ERROR)
          return
        end
        actions.close(prompt_bufnr)
        local ok, err = pcall(pterm.open, name, argv)
        if not ok then
          vim.notify("Failed to open session '" .. name .. "': " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      local extension = telescope.extensions.pterm
      local sessions = extension.sessions
      local function configured_sessions(opts)
        opts = vim.tbl_extend("force", {}, opts or {})
        local attach = opts.attach_mappings
        opts.prompt_title = opts.prompt_title or "pterm sessions | new: name [command args...]"
        opts.attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace_if(function()
            return action_state.get_selected_entry() == nil
          end, function()
            create_session(prompt_bufnr)
          end)
          if attach then
            return attach(prompt_bufnr, map)
          end
          return true
        end
        return sessions(opts)
      end
      extension.sessions = configured_sessions
      extension.pterm = configured_sessions
    ''
  );
  extraPackages = with pkgs; [ pterm-daemon ];
}
