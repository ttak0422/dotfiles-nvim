{ pkgs, ... }:
let
  read = builtins.readFile;
in
with pkgs.vimPlugins;
rec {
  dap = {
    packages = [
      nvim-dap
      nvim-dap-virtual-text
      nvim-dap-repl-highlights
    ];
    postConfig = read ../lua/autogen/dap.lua;
    hooks.modules = [ "dap" ];
  };
  dap-go = {
    package = nvim-dap-go;
    extraPackages = with pkgs; [ delve ];
    postConfig = read ../lua/autogen/dap-go.lua;
    hooks.fileTypes = [ "go" ];
  };
  dap-ui = {
    package = nvim-dap-ui;
    depends = [ dap ];
    postConfig = read ../lua/autogen/dap-ui.lua;
    hooks.modules = [ "dap-ui" ];
  };
}
