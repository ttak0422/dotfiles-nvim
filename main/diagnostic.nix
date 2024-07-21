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
  dd = {
    package = nvim-dd;
    postConfig = read ../lua/autogen/dd.lua;
    hooks.events = [ "InsertEnter" ];
  };
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
