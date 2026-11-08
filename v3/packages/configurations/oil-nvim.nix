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
    # oil.nvim

    ## 概要
    通常のバッファ編集に近い操作でファイルシステムを編集する。

    ## 主な機能
    - ファイルやディレクトリーを一覧し、編集内容を保存時に反映する。
    - 列表示、プレビュー、隠しファイル、任意のアイコンを設定できる。

    ## 使い方
    `:Oil <path>` または `:Oil --float <path>` で開く。`<CR>` で項目を開き、一覧の変更後に `:w` でファイル操作を実行する。この定義は既定のディレクトリー表示の置換を無効にしている。

    ## 要件
    Neovim 0.10 以上。mini.icons または nvim-web-devicons は任意のアイコン用。

    ## 出典
    [固定バージョンの README](https://github.com/stevearc/oil.nvim/blob/d3733d933833a0e59b813ecec99341527adf0c28/README.md)
  '';

  plugin = sources.oil-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("oil").setup({
        default_file_explorer = false,
        columns = { "icon", "permissions", "size", "mtime" },
        delete_to_trash = true,
        use_default_keymaps = false,
        lsp_file_methods = { timeout_ms = 5000 },
        view_options = {
          show_hidden = true,
          is_hidden_file = function() return false end,
          is_always_hidden = function() return false end,
          sort = { { "type", "asc" }, { "name", "asc" } },
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          e = "actions.select",
          ["<C-w>v"] = "actions.select_vsplit",
          ["<C-w>s"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          q = "actions.close",
          ["<C-c>"] = "actions.close",
          R = "actions.refresh",
          H = "actions.parent",
          L = "actions.select",
        },
        keymaps_help = { border = "none" },
      })
    ''
  );
}
