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
  plugin = sources.better-escape-nvim;
  config = luaConfig (
    # lua
    ''
      require("better_escape").setup({
        default_mappings = false,
        mappings = {
          i = { j = { k = "<Esc>" } },
          c = {},
          t = { j = { k = "<C-\\><C-n>" } },
          v = {},
          s = {},
        },
      })
    ''
  );
}
