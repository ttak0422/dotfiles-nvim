{ pkgs }:
let
  sources = import ../npins;
in
{
  skk = import ./skk { inherit pkgs sources; };
}
