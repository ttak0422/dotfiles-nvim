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
  plugin = sources.lookup-nvim;
  dependPlugins = [
    definitions.telescope-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("lookup").setup({ use_lsp = true, picker = "telescope" })
    ''
  );
}
