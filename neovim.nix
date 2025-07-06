{ inputs, ... }:
{
  imports = [
    inputs.bundler.flakeModules.neovim
  ];
  perSystem =
    params@{
      inputs',
      self',
      system,
      pkgs,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = import ./overlays.nix inputs;
      };

      bundler-nvim = {
        v2 = import ./v2 params;
      };
    };
}
