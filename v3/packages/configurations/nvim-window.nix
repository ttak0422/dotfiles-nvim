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
  plugin = sources.nvim-window;
  config = luaConfig (
    # lua
    ''
      require("nvim-window").setup({})
    ''
  );
}
