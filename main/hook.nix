{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
{
  hookInsert = {
    postConfig = read ../lua/autogen/hook-insert.lua;
    hooks.events = [ "InsertEnter" ];
  };
  hookBuffer = {
    preConfig = read ../lua/autogen/hook-buffer.lua;
    depends = [
      # use snacks
      # {
      #   package = bigfile-nvim;
      #   postConfig = read ../lua/autogen/bigfile.lua;
      # }
      {
        package = statuscol-nvim;
        postConfig = read ../lua/autogen/statuscol.lua;
      }
      {
        package = nvim-ufo;
        depends = [
          promise-async
          treesitter.treesitter
        ];
        postConfig = read ../lua/autogen/ufo.lua;
      }
      {
        package = auto-save-nvim;
        postConfig = read ../lua/autogen/auto-save.lua;
      }
      {
        package = dmacro-vim;
        postConfig = {
          code = ''
            inoremap <C-d> <Plug>(dmacro-play-macro)
            nnoremap <C-d> <Plug>(dmacro-play-macro)
          '';
          language = "vim";
        };
      }
    ];
    hooks.events = [ "BufRead" ];
  };
  hookCmdline = {
    postConfig = {
      code = read ../lua/autogen/hook-cmdline.lua;
      args = {
        cabbrev_path = ../vim/cabbrev.vim;
      };
    };
    hooks.events = [ "CmdlineEnter" ];
  };
  hookEdit = {
    depends = [
      {
        package = nvim-lint;
        extraPackages = with pkgs; [
          typos
          checkstyle
        ];
        postConfig = read ../lua/autogen/lint.lua;
      }
      {
        package = copilot-lua;
        extraPackages = with pkgs; [ nodejs ];
        postConfig = read ../lua/autogen/copilot.lua;
      }
      {
        package = nvim-surround;
        postConfig = read ../lua/autogen/surround.lua;
      }
      # {
      #   package = endscroll-nvim;
      #   postConfig = read ../lua/autogen/endscroll.lua;
      # }
      # {
      #   package = highlight-undo-nvim;
      #   postConfig = read ../lua/autogen/highlight-undo.lua;
      # }
    ];
    postConfig = read ../lua/autogen/hook-edit.lua;
    hooks.events = [
      "InsertEnter"
      "CursorMoved"
    ];
  };
  hookWindow = {
    depends = [
      {
        package = bufresize-nvim;
        postConfig = read ../lua/autogen/bufresize.lua;
      }
      {
        package = winresizer;
        preConfig = {
          language = "vim";
          code = read ../vim/winresizer.vim;
        };
      }
    ];
    postConfig = read ../lua/autogen/hook-window.lua;
    hooks.events = [ "WinNew" ];
  };
  hookTerm = {
    postConfig = read ../lua/autogen/hook-term.lua;
    hooks.events = [ "TermOpen" ];
  };
}
