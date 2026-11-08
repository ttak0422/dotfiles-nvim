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
  plugin = nui-nvim;
  doc = "Enabled v2/default nui configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
