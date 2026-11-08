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
  plugin = sources.helpview-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("helpview").setup({ preview = { modes = { "n", "c", "no" } }, vimdoc = {} })
    ''
  );
}
