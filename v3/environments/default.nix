{ pkgs, inputs' }:
import ./shared.nix {
  inherit pkgs inputs';
  environment = "default";
}
