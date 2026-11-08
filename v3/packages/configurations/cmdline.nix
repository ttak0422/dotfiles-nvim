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
  plugin = tiny-cmdline-nvim;
  config = luaConfig (
    # lua
    ''
      return require("tiny-cmdline").setup({on_reposition = require("tiny-cmdline").adapters.blink, native_types = {}})
    ''
  );
  doc = "Enabled v2/default cmdline configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
