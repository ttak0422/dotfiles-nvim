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
  plugin = scope-nvim;
  config = luaConfig (
    # lua
    ''
      return require("scope").setup()
    ''
  );
  doc = "Enabled v2/default scope configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
