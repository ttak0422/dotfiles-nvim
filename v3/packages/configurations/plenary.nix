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
  plugin = plenary-nvim;
  doc = "Enabled v2/default plenary configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
