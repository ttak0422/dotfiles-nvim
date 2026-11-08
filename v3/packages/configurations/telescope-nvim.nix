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
    # telescope.nvim

    ## 概要
    一覧を検索・選択・プレビューする拡張可能なファジーファインダー。

    ## 主な機能
    - ファイル、バッファ、ヘルプなどの組み込み picker を提供する。
    - picker、ソーター、プレビュー、レイアウトを個別に拡張できる。

    ## 使い方
    `:Telescope find_files`、`:Telescope buffers`、`:Telescope help_tags` を使う。全文検索には `require("telescope.builtin").live_grep()`、導入確認には `:checkhealth telescope` を使う。

    ## 要件
    LuaJIT 付き Neovim 0.11.7 以上と plenary.nvim。live_grep / grep_string には ripgrep が必要。fd、アイコン、ネイティブソーターは推奨の追加機能。

    ## 出典
    [固定バージョンの README](https://github.com/nvim-telescope/telescope.nvim/blob/40aedd8a68c78a656a10a8d62d80c54af59420fb/README.md)
  '';

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
