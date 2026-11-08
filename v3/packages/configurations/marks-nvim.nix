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
  plugin = sources.marks-nvim;
  config = luaConfig (
    # lua
    ''
      require("marks").setup({
        default_mappings = true,
        refresh_interval = 500,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      })
    ''
  );
}
