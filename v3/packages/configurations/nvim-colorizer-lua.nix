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
  plugin = sources.nvim-colorizer-lua;
  config = luaConfig (
    # lua
    ''
      require("colorizer").setup()
    ''
  );
}
