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
  plugin = sources.diffview-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("diffview").setup({
        icons = { folder_closed = "", folder_open = "" },
        signs = { fold_closed = "▸", fold_open = "▾", done = "✓" },
      })
    ''
  );
}
