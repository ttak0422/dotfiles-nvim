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
  plugin = snacks-nvim;
  config = luaConfig (
    # lua
    ''
      local snacks = require("snacks")
      local bigfile = {notify = true, size = (1 * 1024 * 1024), line_length = 2000}
      return snacks.setup({bigfile = bigfile})
    ''
  );
  doc = "Enabled v2/default snacks configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
