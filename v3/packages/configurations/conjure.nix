{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = sources.conjure;
  preConfig = luaConfig (
    # lua
    ''
      vim.g["conjure#mapping#doc_word"] = "K"
      return nil
    ''
  );
  doc = "Enabled v2/default conjure configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
