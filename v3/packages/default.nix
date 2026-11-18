{
  pkgs,
  inputs',
  environment ? "default",
}:
let
  sources = import ./sources.nix { inherit pkgs inputs'; };
  configurations = import ./configurations { inherit pkgs sources inputs' environment; };
  core = import ./core {
    inherit pkgs;
    nginxPlugin = sources.nginx-vim;
  };
in
{
  inherit core configurations sources;
}
