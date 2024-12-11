{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  language = callPackage ./language.nix { };
  lib = callPackage ./lib.nix { };
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  trouble = {
    package = trouble-nvim;
    depends = [
      language.lsp
      lib.devicons
      treesitter.treesitter
    ];
    postConfig = read ../lua/autogen/trouble.lua;
    hooks = {
      modules = [ "trouble" ];
      commands = [ "TroubleToggle" ];
    };
  };
}
