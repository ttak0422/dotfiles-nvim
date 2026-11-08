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
  plugin = pkgs.vimPlugins.vim-matchup;
  config = luaConfig ''
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
    vim.g.matchup_treesitter_stopline = 500
  '';
}
