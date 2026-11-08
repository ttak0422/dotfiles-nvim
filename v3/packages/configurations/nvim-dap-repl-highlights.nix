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
  plugin = sources.nvim-dap-repl-highlights;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-dap-repl-highlights").setup()
  '';
}
