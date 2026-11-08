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
  plugin = sources.sorairo;
  doc = "Enabled v2/default sorairo configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
