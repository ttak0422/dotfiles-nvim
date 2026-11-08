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
  plugin = vim-jsonl;
  doc = "Enabled v2/default jsonl configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
