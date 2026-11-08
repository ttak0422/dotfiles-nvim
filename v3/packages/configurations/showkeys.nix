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
  plugin = sources.showkeys;
  dependPlugins = [
    definitions.volt
  ];
}
