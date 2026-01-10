{
  inputs',
  pkgs,
}:
let
  import' = p: import p { inherit inputs' pkgs; };
in
{
  kotlin-nvim = import' ./kotlin-nvim.nix;
  treesitter = import' ./treesitter.nix;
  videre = import' ./videre.nix;
}
