{ inputs, ... }:
{
  imports = [
    inputs.bundler.flakeModules.neovim
    inputs.loaded-nvim.flakeModule
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

      loaded-nvim' =
        let
          common = {
            # did_load_ftplugin = true;
            # did_indent_on = true;
            did_install_default_menus = true;
            skip_loading_mswin = true;
            loaded_gzip = true;
            loaded_man = true;
            loaded_matchit = true;
            loaded_matchparen = true;
            loaded_netrwPlugin = true;
            loaded_remote_plugins = true;
            loaded_shada_plugin = true;
            loaded_spellfile_plugin = true;
            loaded_tarPlugin = true;
            loaded_2html_plugin = true;
            loaded_tutor_mode_plugin = true;
            loaded_zipPlugin = true;
          };
        in
        {
          default = common // {
            package = pkgs.pkgs-stable.neovim;
          };
          nightly = common // {
            package = pkgs.neovim;
          };
        };

      bundler-nvim = {
        inherit (import ./full.nix params) v9 nightly;
      };
    };
}
