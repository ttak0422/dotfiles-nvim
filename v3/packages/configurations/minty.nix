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
  plugin = sources.minty;
  dependPlugins = [
    definitions.volt
  ];
}
