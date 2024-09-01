{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  snippet = callPackage ./snippet.nix { };
  quickfix = callPackage ./quickfix.nix { };
in
with pkgs.vimPlugins;
rec {
  telescope = {
    packages = [
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-live-grep-args-nvim
      telescope-sonictemplate-nvim
      telescope-sg
    ];
    depends = [
      lib.plenary
      snippet.sonictemplate
      quickfix.bqf
    ];
    postConfig = read ../lua/autogen/telescope.lua;
    extraPackages = with pkgs; [
      # for live-grep-args
      ripgrep
      # for sg
      ast-grep
    ];
    hooks.commands = [ "Telescope" ];
  };
  asterisk = {
    package = vim-asterisk;
    postConfig = {
      language = "vim";
      code = read ../vim/asterisk.vim;
    };
    hooks.events = [ "CursorMoved" ];
  };
  hlslens = {
    package = nvim-hlslens;
    postConfig = read ../lua/autogen/hlslens.lua;
    hooks.events = [ "CmdlineEnter" ];
  };
  legendary = {
    package = legendary-nvim;
    depends = [
      {
        package = sqlite-lua;
        preConfig = {
          language = "vim";
          code = ''
            if has('mac')
            let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.dylib'
            else
            let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'
            endif
          '';
        };
      }
      telescope
    ];
    postConfig = read ../lua/autogen/legendary.lua;
    hooks.commands = [ "Legendary" ];
  };
  reacher = {
    package = reacher-nvim;
    postConfig = read ../lua/autogen/reacher.lua;
    hooks.modules = [ "reacher" ];
  };
  fzf = {
    preConfig = ''
      source ${pkgs.fzf}/share/nvim/site/plugin/fzf.vim
    '';
  };
  fzf-lua = {
    package = pkgs.vimPlugins.fzf-lua;
    depends = [
      lib.devicons
      fzf
    ];
    extraPackages = with pkgs; [
      fd
      ripgrep
      bat
      delta
    ];
    postConfig = read ../lua/autogen/fzf-lua.lua;
  };
}
