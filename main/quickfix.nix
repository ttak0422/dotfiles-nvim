{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  bqf = {
    package = nvim-bqf;
    depends = [
      treesitter.treesitter
      # neotestと相性が良くない
      # {
      #   package = nvim-pqf;
      #   postConfig = read ../lua/autogen/pqf.lua;
      # }
    ];
    postConfig = read ../lua/autogen/bqf.lua;
    hooks.events = [
      "QuickFixCmdPost"
      "CmdlineEnter"
    ];
  };
  qf = {
    package = qf-nvim;
    postConfig = read ../lua/autogen/qf.lua;
    hooks = {
      fileTypes = [ "qf" ];
      commands = [
        "Qnext"
        "Qprev"
        "Lnext"
        "Lprev"
      ];
    };
  };
  qfreplace = {
    package = vim-qfreplace;
    hooks = {
      fileTypes = [ "qf" ];
      commands = [ "Qfreplace" ];
    };
  };
}
