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
  plugin = sources.fix-auto-scroll-nvim;
  config = luaConfig (
    # lua
    ''
      require("fix-auto-scroll").setup()
    ''
  );
}
