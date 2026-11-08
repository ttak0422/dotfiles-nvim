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
  plugin = sources.tiny-cmdline-nvim;
  config = luaConfig (
    # lua
    ''
      local cmdline = require("tiny-cmdline")
      cmdline.setup({
        on_reposition = cmdline.adapters.blink,
        native_types = {},
      })
    ''
  );
}
