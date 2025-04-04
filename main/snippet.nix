{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  treesitter = callPackage ./treesitter.nix { };
  input = callPackage ./input.nix { };
in
with pkgs.vimPlugins;
rec {
  sonictemplate = {
    package = vim-sonictemplate.overrideAttrs (old: {
      src = pkgs.nix-filter {
        root = vim-sonictemplate.src;
        exclude = [
          "template/java"
          "template/make"
        ];
      };
    });
    preConfig =
      let
        template = pkgs.stdenv.mkDerivation {
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
  vsnip = {
    packages = [ vim-vsnip ];
    depends = [ input.tabout ];
    preConfig = {
      language = "vim";
      code = read ../vim/vsnip.vim;
    };
    hooks.events = [ "InsertEnter" ];
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
      vsnip
      # LuaSnip
      treesitter.treesitter
    ];
    postConfig = read ../lua/autogen/neogen.lua;
    hooks = {
      modules = [ "neogen" ];
      commands = [ "Neogen" ];
    };
  };
}
