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
  plugin = vim-asterisk;
  doc = "Enabled v2/default asterisk configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
