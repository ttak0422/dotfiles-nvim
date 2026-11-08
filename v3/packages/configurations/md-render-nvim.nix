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
  plugin = sources.md-render-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
    definitions.budoux-lua
  ];
}
