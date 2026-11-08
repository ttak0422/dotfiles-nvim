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
  plugin = sources.fidget-nvim;
  config = luaConfig (
    # lua
    ''
      require("fidget").setup({})
    ''
  );
}
