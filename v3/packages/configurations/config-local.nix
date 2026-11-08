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
  plugin = nvim-config-local;
  doc = "Enabled v2/default config-local configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
