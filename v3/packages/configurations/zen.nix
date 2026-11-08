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
  plugin = zen-nvim;
  config = luaConfig (
    # lua
    ''
      local zen = require("zen")
      return zen.setup({})
    ''
  );
  doc = "Enabled v2/default zen configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
