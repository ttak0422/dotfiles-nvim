{ pkgs, ... }:
let
  read = builtins.readFile;
in
with pkgs.vimPlugins;
{
  hookInsert = {
    postConfig = read ../lua/autogen/hook-insert.lua;
    hooks.events = [ "InsertEnter" ];
  };
  hookBuffer = {
    postConfig = read ../lua/autogen/hook-buffer.lua;
    hooks.events = [ "BufReadPost" ];
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
      {
        package = endscroll-nvim;
        postConfig = read ../lua/autogen/endscroll.lua;
      }
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
