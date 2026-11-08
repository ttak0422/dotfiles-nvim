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
  plugin = sources.treesj;
  config = luaConfig (
    # lua
    ''
      require("treesj").setup({ use_default_keymaps = false })
    ''
  );
}
