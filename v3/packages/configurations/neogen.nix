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
  plugin = sources.neogen;
  dependPlugins = [
    definitions.LuaSnip
  ];
  config = luaConfig (
    # lua
    ''
      require("neogen").setup({ snippet_engine = "luasnip" })
    ''
  );
}
