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
  plugin = sources.telescope-nvim;
  dependPlugins = [
    definitions.plenary-nvim
    definitions.telescope-fzf-native-nvim
    definitions.telescope-ghq-nvim
    definitions.telescope-live-grep-args-nvim
    definitions.telescope-sonictemplate-nvim
    definitions.telescope-ui-select-nvim
    definitions.project-nvim
    definitions.vim-sonictemplate
    definitions.worktab-nvim
  ];
  extraPackages = with pkgs; [
    ripgrep
    ghq
  ];
  config = luaConfig (
    # lua
    ''
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          prompt_prefix = " ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.87,
            height = 0.8,
          },
          mappings = {
            i = {
              ["<C-j>"] = { "<Plug>(goda-skk-enable)", type = "command" },
              ["<Down>"] = actions.cycle_history_next,
              ["<Up>"] = actions.cycle_history_prev,
            },
            n = {
              ["<Down>"] = actions.cycle_history_next,
              ["<Up>"] = actions.cycle_history_prev,
            },
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-t>"] = lga_actions.quote_prompt({ postfix = " -t " }),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
            additional_args = function()
              return { "--hidden", "--glob", "!.git/**" }
            end,
          },
        },
      })
      for _, extension in ipairs({ "ui-select", "live_grep_args", "sonictemplate", "projects", "ghq", "worktab" }) do
        telescope.load_extension(extension)
      end
      vim.api.nvim_create_user_command("TelescopeBuffer", function()
        builtin.live_grep({ grep_open_files = true })
      end, {})
      vim.api.nvim_create_user_command("TelescopeBufferName", function()
        builtin.buffers({ sort_mru = true, ignore_current_buffer = false })
      end, {})
    ''
  );
}
