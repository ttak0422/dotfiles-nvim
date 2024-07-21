{ self', pkgs, ... }:
let
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (pkgs.stdenv) mkDerivation;
  read = builtins.readFile;
  package = self'.packages.loaded-nvim-nightly;
  extraPackages = [ ];
  extraConfig = read ./../lua/autogen/prelude.lua;
  after = { };

  eager = {
    morimo.package = pkgs.vimPlugins.morimo;
    config-local.package = pkgs.vimPlugins.nvim-config-local;
  };

  lazy = { };
in
rec {
  inherit
    package
    extraPackages
    extraConfig
    after
    eager
    lazy
    ;
}
