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
  plugin = sources.keep-split-ratio-nvim;
  config = luaConfig (
    # lua
    ''
      require("keep-split-ratio").setup()
    ''
  );
}
