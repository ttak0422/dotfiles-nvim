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
