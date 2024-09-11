{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  diagnostic = callPackage ./diagnostic.nix { };
in
with pkgs.vimPlugins;
{
  direnv = {
    package = direnv-vim;
    postConfig = read ../lua/direnv.lua;
    hooks.events = [ "DirChangedPre" ];
  };
  fundo = {
    package = nvim-fundo;
    depends = [ promise-async ];
    postConfig = read ../lua/autogen/fundo.lua;
    hooks.events = [ "BufReadPost" ];
  };
  history-ignore = {
    package = history-ignore-nvim;
    postConfig = read ../lua/autogen/history-ignore.lua;
    hooks.events = [ "CmdlineEnter" ];
  };
  lastplace = {
    package = nvim-lastplace;
    preConfig = {
      code = read ../lua/autogen/lastplace-pre.lua;
      args = {
        exclude_ft_path = ../lua/autogen/exclude_ft.lua;
        exclude_buf_ft_path = ../lua/autogen/exclude_buf_ft.lua;
      };
    };
    hooks.events = [ "BufReadPre" ];
  };
  mkdir = {
    package = mkdir-nvim;
    hooks.events = [ "CmdlineEnter" ];
  };
  open = {
    package = open-nvim;
    depends = [ lib.plenary ];
    postConfig =
    {
     code = read ../lua/autogen/open.lua;
     args = {
       cmd = if pkgs.stdenv.isDarwin then "open" else "xdg-open";
     };
    };
    hooks.modules = [ "open" ];
  };
  project = {
    package = project-nvim;
    postConfig = read ../lua/autogen/project.lua;
    hooks.events = [ "BufReadPost" ];
  };
  registers = {
    package = registers-nvim;
    postConfig = read ../lua/autogen/registers.lua;
    hooks.events = [ "CursorMoved" ];
  };
  smart-splits = {
    package = smart-splits-nvim;
    postConfig = read ../lua/autogen/smart-splits.lua;
    hooks = {
      modules = [ "smart-splits" ];
      events = [ "WinNew" ];
    };
  };
  stickybuf = {
    package = stickybuf-nvim;
    postConfig = read ../lua/autogen/stickybuf.lua;
    hooks.events = [ "BufReadPost" ];
  };
  todo-comments = {
    package = todo-comments-nvim;
    depends = [
      lib.plenary
      lib.devicons
      diagnostic.trouble
    ];
    extraPackages = with pkgs; [ ripgrep ];
    postConfig = read ../lua/autogen/todo-comments.lua;
    hooks.events = [ "BufReadPost" ];
  };
  toolwindow = {
    package = toolwindow-nvim;
    hooks.modules = [ "toolwindow" ];
  };
  trim = {
    package = trim-nvim;
    postConfig = read ../lua/autogen/trim.lua;
    hooks.events = [ "BufWritePre" ];
  };
  vimdoc-ja = {
    package = pkgs.vimPlugins.vimdoc-ja;
    hooks.events = [ "CmdlineEnter" ];
  };
  waitevent = {
    package = waitevent-nvim;
    postConfig = read ../lua/autogen/waitevent.lua;
    hooks.events = [ "BufReadPost" ];
  };
  whichkey = {
    package = which-key-nvim;
    postConfig = read ../lua/autogen/whichkey.lua;
    hooks.events = [ "CursorMoved" ];
  };
  winshift = {
    package = winshift-nvim;
    postConfig = read ../lua/autogen/winshift.lua;
    hooks.commands = [ "WinShift" ];
  };
  bufdel = {
    package = nvim-bufdel;
    postConfig = read ../lua/autogen/bufdel.lua;
    hooks.commands = [
      "BufDel"
      "BufDel!"
      "BufDelAll"
    ];
  };
  fix-auto-scroll = {
    package = fix-auto-scroll-nvim;
    postConfig = read ../lua/autogen/fix-auto-scroll.lua;
    hooks.events = [ "BufReadPost" ];
  };
}
