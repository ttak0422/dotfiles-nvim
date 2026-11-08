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
  plugin = sources.nvim-ts-context-commentstring;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
}
