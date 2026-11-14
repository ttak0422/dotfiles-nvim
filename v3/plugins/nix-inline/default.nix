{ pkgs }:
pkgs.vimUtils.buildVimPlugin {
  pname = "nix-inline";
  version = "0.1.0";
  src = ./.;
}
