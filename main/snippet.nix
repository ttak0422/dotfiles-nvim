{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  sonictemplate = {
    package = vim-sonictemplate;
    preConfig =
      let
        template = mkDerivation {
          pname = "sonictemplate";
          version = "custom";
          src = ../tmpl/sonic;
          installPhase = ''
            mkdir $out
            cp -r ./* $out
          '';
        };
      in
      ''
        vim.g.sonictemplate_vim_template_dir = "${template}"
        vim.g.sonictemplate_key = 0
        vim.g.sonictemplate_intelligent_key = 0
        vim.g.sonictemplate_postfix_key = 0
      '';
  };
  LuaSnip = {
    package = pkgs.vimPlugins.LuaSnip;
    postConfig = read ../lua/autogen/luasnip.lua;
  };
  flow = {
    package = flow-nvim;
    postConfig = read ../lua/autogen/flow.lua;
    hooks.commands = [
      "FlowRunSelected"
      "FlowRunFile"
      "FlowLauncher"
    ];
  };
  neogen = {
    package = pkgs.vimPlugins.neogen;
    depends = [
      # vim-vsnip
      LuaSnip
      treesitter.treesitter
    ];
    postConfig = read ../lua/autogen/neogen.lua;
    hooks = {
      modules = [ "neogen" ];
      commands = [ "Neogen" ];
    };
  };
}
