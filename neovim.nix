{ inputs, ... }:
{
  imports = [
    inputs.bundler.flakeModules.neovim
  ];
  perSystem =
    params@{
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
        main = import ./main params;
        tiny = {
          eager = {
            morimo.package = pkgs.vimPlugins.morimo;
            config-local.package = pkgs.vimPlugins.nvim-config-local;
            sorairo.package = pkgs.vimPlugins.sorairo;
            ayu.package = pkgs.vimPlugins.ayu-vim;
          };
        };
      };
    };
}
