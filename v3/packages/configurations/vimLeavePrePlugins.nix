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
  plugin = emptyPlugin "vimLeavePrePlugins";
  dependPlugins = [
    {
      plugin = logrotate-nvim;
      config = luaConfig (
        # lua
        ''
          local logrotate = require("logrotate")
          return logrotate.setup({targets = {(vim.fn.stdpath("state") .. "/lsp.log")}, interval = "daily"})
        ''
      );
    }
  ];
  doc = "Enabled v2/default vimLeavePrePlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
