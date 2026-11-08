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
  plugin = sources.no-neck-pain-nvim;
  config = luaConfig (
    # lua
    ''
      require("no-neck-pain").setup({ buffers = { right = { enabled = false } } })
    ''
  );
}
