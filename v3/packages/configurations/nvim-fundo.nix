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
  plugin = sources.nvim-fundo;
  dependPlugins = [
    definitions.promise-async
  ];
  config = luaConfig (
    # lua
    ''
      require("fundo").setup()
    ''
  );
}
