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
  plugin = nvim-dap-ui;
  dependPlugins = [
    dap
    nio
    devicons
  ];
  config = luaConfig (
    # lua
    ''
      local ui = require("dapui")
      local icons = {expanded = "\226\150\190", collapsed = "\226\150\184", current_frame = "\226\150\184"}
      return ui.setup({icons = icons})
    ''
  );
  doc = "Enabled v2/default dap-ui configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
