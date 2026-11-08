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
  plugin = sources.cmp-nvim-lsp;
  dependPlugins = [
    definitions.nvim-cmp
  ];
}
