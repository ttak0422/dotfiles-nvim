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
  plugin = sources.which-key-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("which-key").setup({
        preset = "helix",
        delay = function(context)
          return context.plugin and 50 or 200
        end,
        icons = { mappins = true, rules = false },
      })
    ''
  );
}
