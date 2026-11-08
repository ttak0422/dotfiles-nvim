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
  plugin = mdpaste-nvim;
  doc = "Enabled v2/default mdpaste configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
