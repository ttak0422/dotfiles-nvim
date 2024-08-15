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
    norg = {
      language = "vim";
      code = read ../vim/after/neorg.vim;
    };
    ddu-ff = {
      language = "vim";
      code = read ../vim/after/ddu-ui-ff.vim;
    };
    NeogitStatus = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
    NeogitCommitView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
    NeogitDiffView = {
      language = "vim";
      code = ''
        setlocal foldcolumn=0
      '';
    };
  };
in
{
  inherit plugin ftplugin;
}
