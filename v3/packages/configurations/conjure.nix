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
  plugin = sources.conjure;
  preConfig = luaConfig (
    # lua
    ''
      vim.g["conjure#mapping#doc_word"] = "K"
    ''
  );
}
