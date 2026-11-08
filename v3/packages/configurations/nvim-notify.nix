{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  plugin = sources.nvim-notify;
  config = luaConfig (
    # lua
    ''
      local notify = require("notify")
      notify.setup({
        timeout = 2500,
        render = "default",
        top_down = true,
        stages = "static",
        background_colour = "#000000",
      })
      vim.notify = notify
    ''
  );
}
