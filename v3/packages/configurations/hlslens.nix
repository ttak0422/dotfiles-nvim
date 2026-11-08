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
  plugin = nvim-hlslens;
  config = luaConfig (
    # lua
    ''
      require("hlslens").setup()
    ''
  );
  doc = "Enabled v2/default hlslens configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
