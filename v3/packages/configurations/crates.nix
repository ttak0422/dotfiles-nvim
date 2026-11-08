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
  plugin = crates-nvim;
  doc = "Enabled v2/default crates configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
