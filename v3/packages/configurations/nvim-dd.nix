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
  plugin = sources.nvim-dd;
  config = luaConfig (
    # lua
    ''
      require("dd").setup()
    ''
  );
}
