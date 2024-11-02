{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
rec {
  dap = {
    packages = [
      nvim-dap
      nvim-dap-virtual-text
      nvim-dap-repl-highlights
    ];
    depends = [
      # for repl-highlights
      treesitter.treesitter
    ];
    postConfig =
      ''
        require("morimo").load("dap")
      ''
      + read ../lua/autogen/dap.lua;
    hooks.modules = [ "dap" ];
  };
  dap-go = {
    package = nvim-dap-go;
    extraPackages = with pkgs; [ delve ];
    postConfig = read ../lua/autogen/dap-go.lua;
    hooks.fileTypes = [ "go" ];
  };
  dap-ui = {
    package = nvim-dap-ui;
    depends = [
      dap
      lib.nio
      lib.devicons
    ];
    postConfig = read ../lua/autogen/dap-ui.lua;
    hooks = {
      modules = [ "dapui" ];
      # HACK: improve stability
      commands = [ "ToggleDapUI" ];
    };
  };
}
