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
  plugin = sources.cmp_luasnip;
  dependPlugins = [
    definitions.nvim-cmp
    definitions.LuaSnip
  ];
}
