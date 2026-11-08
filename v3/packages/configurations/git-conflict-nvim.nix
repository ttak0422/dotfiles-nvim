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
  plugin = sources.git-conflict-nvim;
  config = luaConfig (
    # lua
    ''
      require("git-conflict").setup()
    ''
  );
}
