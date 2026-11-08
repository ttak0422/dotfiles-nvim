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
  plugin = sources.nvim-scrollbar;
  dependPlugins = [
    definitions.gitsigns-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("scrollbar").setup({
        throttle_ms = 250,
        handle = { blend = 0 },
        handlers = { gitsigns = true, cursor = false },
      })
    ''
  );
}
