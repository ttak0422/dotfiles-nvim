{ pkgs, ... }:
let
  read = builtins.readFile;
in
with pkgs.vimPlugins;
{
  plenary.package = plenary-nvim;
  nio.package = nvim-nio;
  nui.package = nui-nvim;
  devicons = {
    package = nvim-web-devicons;
    postConfig = read ../lua/autogen/devicons.lua;
  };
}
