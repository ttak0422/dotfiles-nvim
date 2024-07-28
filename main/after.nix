{ pkgs, ... }:
let
  read = builtins.readFile;

  plugin = {
    common = {
      language = "vim";
      code = read ../vim/after/common-plugin.vim;
    };
  };

  hashkellTools = ''
    dofile("${pkgs.vimPlugins.haskell-tools-nvim}/ftplugin/haskell.lua")
  '';
  ftplugin = {
    gina-blame = {
      language = "vim";
      code = read ../vim/after/gina-blame.vim;
    };
    cabal = hashkellTools;
    cabalproject = hashkellTools;
    cagbal = hashkellTools;
    lhaskell = hashkellTools;
    neorg = {
      language = "vim";
      code = read ../vim/after/neorg.vim;
    };
    ddu-ff = {
      language = "vim";
      code = read ../vim/after/ddu-ff.vim;
    };
    ddu-ff-filter = {
      language = "vim";
      code = read ../vim/after/ddu-ff-filter.vim;
    };
  };
in
{
  inherit plugin ftplugin;
}
