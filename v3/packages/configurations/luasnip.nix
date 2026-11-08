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
  plugin = LuaSnip;
  config = luaConfig (
    # lua
    ''
      local ls = require("luasnip")
      return ls.setup({})
    ''
  );
  doc = "Enabled v2/default luasnip configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
