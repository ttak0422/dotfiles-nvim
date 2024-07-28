{ pkgs, ... }:
let
  read = builtins.readFile;
in
with pkgs.vimPlugins;
{
  hookLeader = {
    postConfig = read ../lua/autogen/hook-leader.lua;
    hooks.userEvents = [ "TriggerLeader" ];
  };
  hookInsert = {
    postConfig = read ../lua/autogen/hook-insert.lua;
    hooks.events = [ "InsertEnter" ];
  };
  hookBuffer = {
    postConfig = read ../lua/autogen/hook-buffer.lua;
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  hookCmdline = {
    postConfig = read ../lua/autogen/hook-cmdline.lua;
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
    ];
    postConfig = read ../lua/autogen/hook-edit.lua;
    hooks.events = [
      "InsertEnter"
      "CursorMoved"
    ];
  };
  hookWindow = {
    postConfig = read ../lua/autogen/hook-window.lua;
    hooks.events = [ "WinNew" ];
  };
  hookTerm = {
    postConfig = read ../lua/autogen/hook-term.lua;
    hooks.events = [ "TermOpen" ];
  };
}
