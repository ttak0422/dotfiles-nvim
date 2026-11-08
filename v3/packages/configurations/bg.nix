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
  plugin = bg-nvim;
  doc = "Enabled v2/default bg configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
