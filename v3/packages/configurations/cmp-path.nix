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
  plugin = sources.cmp-path;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
