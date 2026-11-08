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
  plugin = kanagawa-nvim;
  doc = "Enabled v2/default kanagawa configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
