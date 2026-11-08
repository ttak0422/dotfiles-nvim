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
  plugin = sources.crates-nvim;
  config = luaConfig (
    # lua
    ''
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          hover = true,
          completion = false,
        },
      })
    ''
  );
}
