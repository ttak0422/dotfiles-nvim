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
  plugin = sources.LuaSnip;
  config = luaConfig (
    # lua
    ''
      require("luasnip").setup({})
    ''
  );
}
