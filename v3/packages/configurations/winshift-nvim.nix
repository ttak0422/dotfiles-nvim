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
  plugin = sources.winshift-nvim;
  config = luaConfig (
    # lua
    ''
      require("winshift").setup({})
    ''
  );
}
