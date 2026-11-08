{ pkgs }:
let
  packages = import ../packages { inherit pkgs; };
in
{
  plugins = [ packages.skk ];
}
