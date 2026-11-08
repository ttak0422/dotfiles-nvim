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
  plugin = sources.codewindow-nvim;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
  config = luaConfig (
    # lua
    ''
      require("codewindow").setup({
        exclude_filetypes = { "undotree", "gitsigns-blame" },
        minimap_width = 10,
        use_lsp = true,
        use_treesitter = true,
        use_git = true,
        width_multiplier = 4,
        z_index = 1,
        show_cursor = true,
        window_border = "none",
        relative = "editor",
        events = { "TextChanged", "InsertLeave", "DiagnosticChanged", "FileWritePost" },
        active_in_terminals = false,
        auto_enable = false,
      })
    ''
  );
}
