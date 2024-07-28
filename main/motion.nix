{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
in
with pkgs.vimPlugins;
rec {
  detour = {
    package = detour-nvim;
    hooks.commands = [
      "Detour"
      "DetourCurrentWindow"
    ];
  };
  leap = {
    package = leap-nvim;
    depends = [ vim-repeat ];
    postConfig = read ../lua/autogen/leap.lua;
    hooks.events = [ "CursorMoved" ];
  };
  flit = {
    package = flit-nvim;
    depends = [ leap ];
    postConfig = read ../lua/autogen/flit.lua;
    hooks.events = [ "CursorMoved" ];
  };
  goto-preview = {
    package = pkgs.vimPlugins.goto-preview;
    postConfig = read ../lua/autogen/goto-preview.lua;
    hooks.commands = [ "goto-preview" ];
  };
  harpoon = {
    package = harpoon-2;
    depends = [ lib.plenary ];
    postConfig = read ../lua/autogen/harpoon.lua;
    hooks.modules = [ "harpoon" ];
  };
  hydra = {
    package = hydra-nvim;
    postConfig = read ../lua/autogen/hydra.lua;
    hooks.commands = [
      "CmdlineEnter"
      "CursorMoved"
    ];
  };
  marks = {
    package = marks-nvim;
    postConfig = read ../lua/autogen/marks.lua;
    hooks = {
      commands = [
        "MarksQFListBuf"
        "MarksQFListGlobal"
      ];
      events = [ "CursorMoved" ];
    };
  };
  BufferBrowser = {
    package = pkgs.vimPlugins.BufferBrowser;
    postConfig = {
      code = read ../lua/autogen/BufferBrowser.lua;
      args.exclude_ft_path = ../lua/autogen/exclude_ft.lua;
    };
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  nap = {
    package = nap-nvim;
    depends = [ BufferBrowser ];
    postConfig = read ../lua/autogen/nap.lua;
    hooks.events = [ "CursorMoved" ];
  };
  nvim-window = {
    package = pkgs.vimPlugins.nvim-window;
    postConfig = read ../lua/autogen/nvim-window.lua;
    hooks.modules = [ "nvim-window" ];
  };
}
