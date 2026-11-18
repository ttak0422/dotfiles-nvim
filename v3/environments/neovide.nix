{ pkgs, inputs' }:
let
  shared = import ./shared.nix {
    inherit pkgs inputs';
    environment = "neovide";
  };
  settings = import ./neovide-settings.nix;
in
shared // { startupConfig = shared.startupConfig + settings.startupConfig; }
