{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = md-render-nvim;
  dependPlugins = [
    devicons
    budoux-lua
  ];
  doc = "Enabled v2/default md-render configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
