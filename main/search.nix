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
  _search = {
    packages = [
      lasterisk-nvim
      nvim-hlslens
    ];
    postConfig = read ../lua/autogen/_search.lua;
    hooks.events = [ "CursorMoved" ];
  };
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
    hooks.commands = [
      "Telescope"
      "TelescopeB"
    ];
    hooks.modules = [ "fzf_lib" ];
  };
  asterisk = {
    package = vim-asterisk;
    postConfig = {
      language = "vim";
      code = read ../vim/asterisk.vim;
    };
    hooks.events = [ "CursorMoved" ];
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
      lib.snacks
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
    preConfig = {
      language = "vim";
      code = "source ${pkgs.fzf}/share/nvim/site/plugin/fzf.vim";
    };
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
