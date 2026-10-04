{ pkgs }:
let
  source = (import ./npins).mimori;
in
pkgs.buildGoModule {
  pname = "mimori";
  version = "0.1.0-${builtins.substring 0 7 source.revision}";
  src = pkgs.lib.cleanSource source;
  vendorHash = "sha256-P7Viwr2hrzrVCac04v9NNePGgLsXQfiEoMe3nIVjkio=";
  subPackages = [ "cmd/mimori" ];
  doCheck = true;
}
