{ inputs', pkgs, ... }:
let
  read =
    path:
    with builtins;
    readFile (./. + (replaceStrings [ "./fnl/" ".fnl" ] [ "/lua/autogen/" ".lua" ] path));
in
{
  package = pkgs.neovim-unwrapped;

  extraPackages = with pkgs; [
    neovim-remote
    inputs'.gitu.packages.gitu
    # gitu
  ];

  extraConfig = ''
    vim.loader.enable()
    ${builtins.readFile ./lua/autogen/init.lua}
  '';

  after =
    let
      x = 1;
    in
    {
    };

  eager = with pkgs.vimPlugins; {
    morimo.package = morimo;
    config-local.package = nvim-config-local;
  };

  lazy = with pkgs.vimPlugins; rec {
    # colorschemes
    sorairo.package = pkgs.vimPlugins.sorairo;

    # utils
    plenary.package = plenary-nvim;
    devicons = {
      package = nvim-web-devicons;
      postConfig = read "./fnl/devicons.fnl";
    };

    bufferPlugins = {
      depends = [
        {
          package = stickybuf-nvim;
          postConfig = read "./fnl/buffer-plugins.fnl";
        }
        {
          package = bufferline-nvim;
          depends = [
            {
              package = scope-nvim;
              postConfig = read "./fnl/scope.fnl";
            }
          ];
          postConfig = read "./fnl/bufferline.fnl";
        }
      ];
      hooks.events = [ "BufReadPost" ];
    };
    togglePlugins = {
      package = pkgs.vimPlugins.toggler;
      extraPackages = with pkgs; [
        (writeShellApplication {
          name = "tmux";
          runtimeInputs = [ ];
          text = ''${tmux}/bin/tmux -f ${writeText "tmux.conf" ''
            set -g status off
            set -g update-environment "NVIM "

            # keymaps
            bind r source-file ${placeholder "out"} \; display-message "Reload!"

            # plugins
            run-shell ${tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
            run-shell ${tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
          ''} "$@"'';
        })
      ];
      postConfig = read "./fnl/toggle-plugins.fnl";
      hooks.modules = [ "toggler" ];
    };

    nap = {
      package = nap-nvim;
      depends = [
        vim-bufsurf
      ];
      postConfig = read "./fnl/nap.fnl";
      hooks.events = [
        "CursorMoved"
        "BufReadPost"
      ];
    };

    toggleterm = {
      package = toggleterm-nvim;
      depends = [
        term-gf-nvim
      ];
      postConfig = read "./fnl/toggleterm.fnl";
      hooks.modules = [ "toggleterm.terminal" ];
    };

    lir = {
      packages = [
        lir-nvim
        lir-git-status-nvim
      ];
      depends = [
        plenary
        devicons
      ];
      postConfig = ''
        require("morimo").load("lir")
        ${read "./fnl/lir.fnl"}
      '';
      hooks.modules = [ "lir.float" ];
    };
    oil = {
      package = oil-nvim;
      depends = [ devicons ];
      postConfig = read "./fnl/oil.fnl";
      hooks.modules = [ "oil" ];
    };

    # treesitters
  };
}
