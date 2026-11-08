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
  plugin = sources.meian;
  config = luaConfig (
    # lua
    ''
      return require("meian").setup()
    ''
  );
  doc = "Enabled v2/default meian configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
