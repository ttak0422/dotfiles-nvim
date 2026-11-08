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
  plugin = nvim-nio;
  doc = "Enabled v2/default nio configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
