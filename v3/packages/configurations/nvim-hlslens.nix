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
  plugin = sources.nvim-hlslens;
  config = luaConfig (
    # lua
    ''
      require("hlslens").setup()
    ''
  );
}
