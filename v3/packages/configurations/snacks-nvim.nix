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
  plugin = sources.snacks-nvim;
  config = luaConfig (
    # lua
    ''
      require("snacks").setup({
        bigfile = {
          notify = true,
          size = 1024 * 1024,
          line_length = 2000,
        },
      })
    ''
  );
}
