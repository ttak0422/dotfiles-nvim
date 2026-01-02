{
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    # extra-trusted-public-keys = [];
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    bundler = {
      url = "github:ttak0422/bundler/v3";
      # url = "path:/Users/tak/ghq/github.com/ttak0422/bundler";
      # url = "path:/home/ttak0422/ghq/github.com/ttak0422/bundler";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
      };
    };

    skk-dict = {
      url = "github:skk-dev/dict";
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

    # v2
    v2-mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    v2-fff-nvim.url = "github:dmtrKovalenko/fff.nvim";
    v2-blink-cmp.url = "github:Saghen/blink.cmp";
    v2-rustowl.url = "github:nix-community/rustowl-flake";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.bundler.flakeModules.neovim ];
      perSystem =
        {
          inputs',
          system,
          pkgs,
          lib,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = import ./overlays.nix { inherit inputs inputs'; };
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "terraform"
              ];
          };
          bundler-nvim = {
            v2 = import ./v2 {
              inherit inputs' pkgs lib;
            };
          }
          // (import ./tests {
            inherit inputs';
            inherit pkgs;
          });
        }
        // import ./apps.nix { inherit pkgs; };
    };
}
