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
  plugin = sources.nvim-grey;
  doc = "Enabled v2/default nvim-grey configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
