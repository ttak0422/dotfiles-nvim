{ pkgs, inputs' }:
let
  sources = import ./sources.nix { inherit pkgs inputs'; };
  configurations = import ./configurations { inherit pkgs sources inputs'; };
  core = import ./core {
    inherit pkgs;
    nginxPlugin = sources.nginx-vim;
  };
in
{
  inherit core configurations sources;
  skk = import ./skk {
    inherit pkgs;
    sources = import ../npins;
  };
}
