{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
in
with pkgs.vimPlugins;
rec {
  no-neck-pain = {
    package = no-neck-pain-nvim;
    postConfig = read ../lua/autogen/no-neck-pain.lua;
    hooks.commands = [ "NoNeckPain" ];
  };
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
    hooks.commands = [ "ToggleTerm" ];
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
  dotfyle-metadata = {
    package = dotfyle-metadata-nvim;
    hooks.commands = [ "DotfyleGenerate" ];
  };
  copilot-chat = {
    package = CopilotChat-nvim;
    depends = [
      copilot-lua
      lib.plenary
    ];
    preConfig = ''
      package.cpath = package.cpath .. ';${pkgs.luajitPackages.tiktoken_core}/lib/lua/5.1/?.so'
    '';
    postConfig = read ../lua/autogen/copilot-chat.lua;
    hooks.commands = [
      "CopilotChat"
      "CopilotChatToggle"
    ];
  };
}
