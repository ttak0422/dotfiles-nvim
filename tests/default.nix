{
  inputs',
  pkgs,
}:
let
  import' = p: import p { inherit inputs' pkgs; };
in
{
  videre = import' ./videre.nix;
}
