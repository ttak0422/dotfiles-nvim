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
  plugin = sources.visual-whitespace-nvim;
  config = luaConfig (
    # lua
    ''
      -- visual-whitespace uses its defaults.
    ''
  );
}
