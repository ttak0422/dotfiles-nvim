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
  plugin = sources.goplements-nvim;
  config = luaConfig (
    # lua
    ''
      require("goplements").setup()
    ''
  );
}
