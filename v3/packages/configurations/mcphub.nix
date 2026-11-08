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
  plugin = mcphub-nvim;
  extraPackages = with pkgs; [
    nodejs
    v2.mcp-hub
    uv
  ];
  dependPlugins = [ plenary ];
  config = luaConfig (
    # lua
    ''
      local hub = require("mcphub")
      return hub.setup({auto_approve = true})
    ''
  );
  doc = "Enabled v2/default mcphub configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
