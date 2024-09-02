{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
in
with pkgs.vimPlugins;
rec {
  jabs = {
    package = JABS-nvim;
    postConfig = read ../lua/autogen/jabs.lua;
    hooks.commands = [ "JABSOpen" ];
  };
  toggleterm = {
    package = toggleterm-nvim;
    depends = [ term-gf-nvim ];
    postConfig =
      ''
        vim.cmd([[tnoremap <S-Space> <Space>]])
      ''
      + read ../lua/autogen/toggleterm.lua;
    hooks.commands = [
      "ToggleTerm"
      "TermToggle"
    ];
  };
  overseer = {
    package = overseer-nvim;
    depends = [ toggleterm ];
    postConfig = read ../lua/autogen/overseer.lua;
    hooks.commands = [ "OverseerRun" ];
  };
  spectre = {
    package = nvim-spectre;
    depends = [
      lib.plenary
      lib.devicons
    ];
    postConfig = read ../lua/autogen/spectre.lua;
    extraPackages = with pkgs; [
      gnused
      ripgrep
    ];
    hooks.modules = [ "spectre" ];
  };
  startuptime = {
    package = vim-startuptime;
    hooks.commands = [ "StartupTime" ];
  };
  window-picker = {
    package = nvim-window-picker;
    postConfig = {
      code = read ../lua/autogen/window-picker.lua;
      args = {
        exclude_ft_path = ../lua/autogen/exclude_ft.lua;
        exclude_buf_ft_path = ../lua/autogen/exclude_buf_ft.lua;
      };
    };
  };
  lir = {
    packages = [
      lir-nvim
      lir-git-status-nvim
    ];
    depends = [
      lib.plenary
      lib.devicons
    ];
    postConfig = ''
      require("morimo").load("lir")
      ${read ../lua/autogen/lir.lua}
    '';
    hooks = {
      modules = [ "lir.float" ];
      events = [ "CmdlineEnter" ];
    };
  };
  oil = {
    packages = [
      oil-nvim
      oil-vcs-status
    ];
    depends = [ lib.devicons ];
    postConfig = read ../lua/autogen/oil.lua;
    hooks.modules = [ "oil" ];
  };
}
