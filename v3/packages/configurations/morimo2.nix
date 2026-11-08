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
  plugin = sources.morimo2;
  doc = "Enabled v2/default morimo2 configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
