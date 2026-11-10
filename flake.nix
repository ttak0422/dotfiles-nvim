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
    # v3 dependencies update independently of the existing v2 profile.
    v3-nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    v3-pterm.url = "github:ttak0422/pterm";
    v3-track = {
      url = "github:ttak0422/track";
      inputs.nixpkgs.follows = "v3-nixpkgs";
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
          regressionChecks = import ./tests/checks.nix { inherit pkgs; };
          v3Base = import inputs.v3-nixpkgs { inherit system; };
          v3Pkgs = import inputs.v3-nixpkgs {
            inherit system;
            overlays = (import ./overlays.nix { inherit inputs inputs'; }) ++ [
              (import ./v3/dependencies.nix)
              (_: _: {
                # v3 uses current nixpkgs recipes, not v2's version overrides.
                inherit (v3Base) neovim-unwrapped jdt-language-server;
              })
            ];
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "copilot-language-server"
                "idea"
                "intellij-idea"
                "terraform"
              ];
          };
          v3Configuration = import ./v3 {
            pkgs = v3Pkgs;
            inherit inputs';
          };
          v3Bundle = inputs.divine.lib.mkBundle {
            pkgs = v3Pkgs;
            configuration = v3Configuration;
          };
          v3Graph = inputs.divine.lib.mkGraph {
            pkgs = v3Pkgs;
            configuration = v3Configuration;
          };
          v3GraphApp = v3Pkgs.writeShellApplication {
            name = "v3-default-graph";
            runtimeInputs = [ v3Pkgs.coreutils ];
            text = ''
              if [[ "''${1:-}" == "--help" || "''${1:-}" == "-h" ]]; then
                printf 'Usage: nix run .#v3/graph -- [OUTPUT.html]\n'
                printf 'Write the v3/default dependency graph (default: v3-default-graph.html).\n'
                printf 'Existing files are never overwritten. No browser is opened.\n'
                exit 0
              fi
              if (( $# > 1 )); then
                echo "Expected at most one output path; see --help." >&2
                exit 2
              fi
              output="''${1:-v3-default-graph.html}"
              if [[ -e "$output" || -L "$output" ]]; then
                printf 'Refusing to overwrite: %s\n' "$output" >&2
                exit 1
              fi
              # Keep the regular-file race protected after the explicit path check.
              set -o noclobber
              cat ${v3Graph} > "$output"
              printf '%s\n' "$output"
            '';
          };
          v3Neovim = v3Pkgs.writeShellScriptBin "nvim" ''
            # Meian uses macOS defaults; retain Nix tools before the OS fallback.
            export PATH="$PATH:/usr/bin"
            export NVIM_APPNAME=nvim-v3-default
            export NVIM_V3_INIT=${v3Bundle}/init.lua
            exec ${v3Pkgs.neovim-unwrapped}/bin/nvim -u ${v3Bundle}/init.lua "$@"
          '';
        in
        {
          packages = lib.optionalAttrs (system == "aarch64-darwin") {
            "v3/default" = v3Neovim;
            "v3/graph" = v3Graph;
          };
          # The graph uses the same complete, macOS-only configuration as v3/default.
          apps = lib.optionalAttrs (system == "aarch64-darwin") {
            "v3/graph" = {
              type = "app";
              program = lib.getExe v3GraphApp;
            };
          };
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
          # CI selects only these pre-existing focused checks. Keeping a separate
          # output avoids evaluating the full v2/v3 packages or v3 inline checks.
          legacyPackages.ci-checks = pkgs.linkFarm "dotfiles-nvim-ci-checks" (
            lib.mapAttrsToList (name: path: { inherit name path; }) regressionChecks
          );
          checks =
            regressionChecks
            // (lib.optionalAttrs (system == "aarch64-darwin") (
              inputs.divine.lib.mkChecks {
                pkgs = v3Pkgs;
                configuration = v3Configuration;
                bundle = v3Bundle;
                neovim = v3Neovim;
              }
            ));
          devShells.default = pkgs.mkShell {
            packages = [ pkgs.npins ];
          };
        };
    };
}
