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
  plugin = sources.aerial-nvim;
  doc = ''
    # aerial.nvim

    ## 概要
    コードの構造を一覧表示し、シンボルへ移動するアウトラインウィンドウ。

    ## 主な機能
    - LSP や Tree-sitter によるシンボル抽出。
    - 通常ウィンドウ・フロート表示とシンボル間移動。

    ## 使い方
    `:AerialToggle` で一覧を開閉し、`:AerialNext`・`:AerialPrev` でシンボル間を移動する。設定は `require("aerial").setup()` に渡す。

    ## 要件
    Neovim 0.11 以降。動作する LSP 設定または Tree-sitter パーサー。nvim-web-devicons などの連携は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/stevearc/aerial.nvim/blob/28fe6e822ae344544c379d60fcb13c9519a1f08a/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("aerial").setup({
        filter_kind = {
          "Class", "Constructor", "Enum", "Function", "Method",
          "Interface", "Module", "Method", "Struct",
        },
        float = {
          border = "single",
          relative = "cursor",
          max_height = 0.9,
          min_height = { 8, 0.1 },
        },
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
        icons = {
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈔",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "󱐋",
          Operator = "󰆕",
          TypeParameter = "󰗴",
        },
        ignore = {
          diff_windows = true,
          filetypes = {},
          buftypes = "special",
          wintypes = "special",
          unlisted_buffers = false,
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          p = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          q = "actions.close",
          o = "actions.tree_toggle",
          za = "actions.tree_toggle",
          O = "actions.tree_toggle_recursive",
          zA = "actions.tree_toggle_recursive",
          l = "actions.tree_open",
          zo = "actions.tree_open",
          L = "actions.tree_open_recursive",
          zO = "actions.tree_open_recursive",
          h = "actions.tree_close",
          zc = "actions.tree_close",
          H = "actions.tree_close_recursive",
          zC = "actions.tree_close_recursive",
          zr = "actions.tree_increase_fold_level",
          zR = "actions.tree_open_all",
          zm = "actions.tree_decrease_fold_level",
          zM = "actions.tree_close_all",
          zx = "actions.tree_sync_folds",
          zX = "actions.tree_sync_folds",
        },
        layout = {
          max_width = 0.8,
          min_width = 0.15,
          default_direction = "float",
          placement = "window",
        },
        lsp = {
          update_when_errors = true,
          update_delay = 600,
          diagnostics_trigger_update = false,
        },
        treesitter = { update_delay = 500 },
        backends = { "treesitter", "lsp" },
      })
    ''
  );
}
