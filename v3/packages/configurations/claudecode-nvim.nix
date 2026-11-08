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
  plugin = sources.claudecode-nvim;
  dependPlugins = [ definitions.snacks-nvim ];
  config = luaConfig (
    # lua
    ''
      require("claudecode").setup({
        terminal = {
          split_side = "right",
          split_width_percentage = 0.45,
          provider = "auto",
          auto_close = true,
        },
        keys = {},
      })
    ''
  );
}
