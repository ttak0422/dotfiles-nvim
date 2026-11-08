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
  plugin = sources.Comment-nvim;
  config = luaConfig (
    # lua
    ''
      require("Comment").setup({})
    ''
  );
}
