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
  plugin = nvim-web-devicons;
  config = luaConfig (
    # lua
    ''
      local M = require("nvim-web-devicons")
      local override_by_filename = {}
      local override_by_extension = {norg = {icon = "\238\152\179", name = "Neorg"}}
      return M.setup({override_by_filename = override_by_filename, override_by_extension = override_by_extension, color_icons = false})
    ''
  );
  doc = "Enabled v2/default devicons configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
