{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://ttak0422.cachix.org"
      "https://ttak0422-pterm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ttak0422.cachix.org-1:8+SW9jr2e4ieB9eaXAiuoS2wKnTqiMf30XdOi6hTIu8="
      "ttak0422-pterm.cachix.org-1:s0zSh4J7l8NrisVESCYNxcSw7rz2vLsGa5fh+E42NDY="
    ];
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    bundler = {
      url = "github:ttak0422/bundler/v3";
      inputs.nixpkgs.follows = "nixpkgs";
      # url = "path:/Users/tak/ghq/github.com/ttak0422/bundler";
      # url = "path:/home/ttak0422/ghq/github.com/ttak0422/bundler";
    };

    skk-dict = {
      url = "github:skk-dev/dict";
      flake = false;
    };

    goda = {
      url = "github:Shougo/goda.vim/v0.7.2";
      flake = false;
    };
    goda-skk = {
      url = "github:Shougo/goda-skk.vim/v0.3.3";
      flake = false;
    };

    # javaPackages
    junit-console = {
      url = "https://repo.maven.apache.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.2/junit-platform-console-standalone-1.10.2.jar";
      flake = false;
    };
    jol = {
      url = "https://repo.maven.apache.org/maven2/org/openjdk/jol/jol-cli/0.17/jol-cli-0.17-full.jar";
      flake = false;
    };

    divine = {
      url = "github:ttak0422/divine";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    # v2
    v2-mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    v2-blink-cmp = {
      url = "github:Saghen/blink.cmp/v1";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    v2-pterm.url = "github:ttak0422/pterm";
    v2-meian = {
      url = "github:ttak0422/meian.nvim";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    v2-track = {
      url = "github:ttak0422/track";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    v2-mimori = {
      url = "github:ttak0422/mimori";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # WIP
    # v2-rustowl.url = "github:nix-community/rustowl-flake";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = builtins.filter (system: system != "x86_64-darwin") (import inputs.systems);
      imports = [ inputs.bundler.flakeModules.neovim ];
      perSystem =
        {
          inputs',
          system,
          pkgs,
          lib,
          ...
        }:
        let
          v3Default = inputs.divine.lib.mkBundle {
            inherit pkgs;
            configuration = import ./v3/default;
          };
          v3Skk = inputs.divine.lib.mkBundle {
            inherit pkgs;
            configuration = import ./v3/skk { inherit pkgs inputs; };
          };
          v3SkkNeovim = pkgs.writeShellScriptBin "nvim" ''
            export NVIM_APPNAME=nvim-v3-skk
            exec ${pkgs.neovim-unwrapped}/bin/nvim -u ${v3Skk}/init.lua "$@"
          '';
          v3Neovim = pkgs.writeShellScriptBin "nvim" ''
            export NVIM_APPNAME=nvim-v3-default
            exec ${pkgs.neovim-unwrapped}/bin/nvim -u ${v3Default}/init.lua "$@"
          '';
        in
        {
          packages.v3-skk = v3SkkNeovim;
          packages.v3-skk-bundle = v3Skk;
          packages.v3-skk-backend = (import ./v3/skk/packages.nix { inherit pkgs inputs; }).binary;
          packages.v3-default = v3Neovim;
          packages.v3-default-bundle = v3Default;
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = import ./overlays.nix { inherit inputs inputs'; };
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "copilot-language-server"
                "idea"
                "terraform"
              ];
          };
          # The full configuration includes macOS-only meian and Kotlin LSP.
          bundler-nvim =
            lib.optionalAttrs (system == "aarch64-darwin") {
              v2 = import ./v2 {
                inherit inputs' pkgs lib;
              };
            }
            // (import ./tests {
              inherit inputs';
              inherit pkgs;
            });
          checks = (import ./tests/checks.nix { inherit pkgs; }) // {
            v3-skk = import ./tests/v3-skk.nix {
              inherit pkgs;
              bundle = v3Skk;
              neovim = v3SkkNeovim;
            };
            v3-default = import ./tests/v3-default.nix {
              inherit pkgs;
              bundle = v3Default;
              neovim = v3Neovim;
            };
          };
        }
        // import ./apps.nix { inherit pkgs; };
    };
}
