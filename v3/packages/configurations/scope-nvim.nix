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
  plugin = sources.scope-nvim;
  config = luaConfig (
    # lua
    ''
      require("scope").setup()
    ''
  );
}
