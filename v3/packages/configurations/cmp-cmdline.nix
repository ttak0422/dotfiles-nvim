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
  plugin = sources.cmp-cmdline;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
