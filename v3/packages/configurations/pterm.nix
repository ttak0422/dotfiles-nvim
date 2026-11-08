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
