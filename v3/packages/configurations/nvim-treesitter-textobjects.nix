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
  plugin = sources.nvim-treesitter-textobjects;
  dependPlugins = [
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })
  '';
}
