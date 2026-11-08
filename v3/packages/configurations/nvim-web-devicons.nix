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
  plugin = sources.nvim-web-devicons;
  config = luaConfig (
    # lua
    ''
      require("nvim-web-devicons").setup({
        color_icons = false,
        override_by_filename = {},
        override_by_extension = {
          norg = { icon = "", name = "Neorg" },
        },
      })
    ''
  );
}
