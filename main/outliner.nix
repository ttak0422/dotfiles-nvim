{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  git = callPackage ./git.nix { };
  input = callPackage ./input.nix { };
  lib = callPackage ./lib.nix { };
  search = callPackage ./search.nix { };
  style = callPackage ./style.nix { };
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  femaco = {
    package = nvim-FeMaco-lua;
    depends = [ treesitter.treesitter ];
    postConfig = read ../lua/autogen/femaco.lua;
    hooks.commands = [ "FeMaco" ];
  };
  img-clip = {
    package = img-clip-nvim;
    postConfig = read ../lua/autogen/img-clip.lua;
    hooks.modules = [ "img-clip" ];
  };
  markdown-preview = {
    package = markdown-preview-nvim;
    hooks.fileTypes = [ "markdown" ];
  };
  mkdnflow = {
    package = mkdnflow-nvim;
    depends = [ lib.plenary ];
    postConfig = read ../lua/autogen/mkdnflow.lua;
    hooks.fileTypes = [ "markdown" ];
  };
  markview = {
    package = markview-nvim;
    depends = [
      treesitter.treesitter
      lib.devicons
    ];
    postConfig = read ../lua/autogen/markview.lua;
    hooks.fileTypes = [ "markdown" ];
  };
  venn = {
    package = venn-nvim;
    hooks.commands = [ "VBox" ];
  };
  neorg = {
    packages = [
      pkgs.vimPlugins.neorg
      neorg-jupyter
      neorg-templates
      neorg-telescope
      lua-utils-nvim
      pathlib-nvim
    ];
    depends = [
      # input.cmp
      lib.nio
      lib.nui
      lib.plenary
      search.telescope
      style.dressing
      treesitter.treesitter
    ];
    postConfig = read ../lua/autogen/neorg.lua;
    hooks = {
      commands = [
        "Neorg"
        "NeorgFuzzySearch"
        "NeorgGit"
        "NeorgGitBranch"
      ];
      # modules = [ "neorg" ];
    };
  };
}
