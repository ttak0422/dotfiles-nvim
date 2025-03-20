{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  search = callPackage ./search.nix { };
  helper = callPackage ./helper.nix { };
in
with pkgs.vimPlugins;
rec {
  diffview = {
    package = diffview-nvim;
    depends = [ lib.devicons ];
    postConfig = read ../lua/autogen/diffview.lua;
    hooks.commands = [
      "DiffviewOpen"
      "DiffviewToggleFiles"
    ];
  };
  gina = {
    package = gina-vim;
    postConfig = {
      language = "vim";
      code = read ../vim/gina.vim;
    };
  };
  git-conflict = {
    package = git-conflict-nvim;
    depends = [ lib.plenary ];
    postConfig = read ../lua/autogen/git-conflict.lua;
    hooks.events = [ "BufReadPost" ];
  };
  gitsigns = {
    package = gitsigns-nvim;
    depends = [ lib.plenary ];
    postConfig =
      ''
        require("morimo").load("gitsigns")
      ''
      + read ../lua/autogen/gitsigns.lua;
    hooks = {
      modules = [ "gitsigns" ];
      events = [ "CursorMoved" ];
      commands = [ "Gitsigns" ];
    };
  };
  octo = {
    package = octo-nvim;
    depends = [
      lib.plenary
      lib.devicons
      search.telescope
    ];
    postConfig = read ../lua/autogen/octo.lua;
    hooks.commands = [ "Octo" ];
  };
}
