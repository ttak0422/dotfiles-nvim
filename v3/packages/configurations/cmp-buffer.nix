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
  plugin = sources.cmp-buffer;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
