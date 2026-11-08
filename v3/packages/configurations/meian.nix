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
  plugin = sources.meian;
  config = luaConfig (
    # lua
    ''
      require("meian").setup()
    ''
  );
}
