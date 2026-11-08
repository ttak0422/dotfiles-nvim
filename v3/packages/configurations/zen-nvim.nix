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
  plugin = sources.zen-nvim;
  config = luaConfig (
    # lua
    ''
      require("zen").setup({})
    ''
  );
}
