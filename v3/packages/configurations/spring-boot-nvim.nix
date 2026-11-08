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
  plugin = sources.spring-boot-nvim;
  dependPlugins = [
    definitions.nvim-jdtls
  ];
}
