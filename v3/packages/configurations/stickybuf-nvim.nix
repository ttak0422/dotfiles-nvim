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
  plugin = sources.stickybuf-nvim;
  config = luaConfig (
    # lua
    ''
      require("stickybuf").setup()
    ''
  );
}
