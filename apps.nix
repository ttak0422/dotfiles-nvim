{ pkgs, ... }:
let
  mkApp =
    {
      name,
      inputs ? [ ],
      script,
    }:
    {
      type = "app";
      program = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = inputs;
        text = script;
      };
    };
in
{
  apps = {
    show-inputs = mkApp {
      name = "show-inputs";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = "nix flake metadata --json | jq -r '.locks.nodes | keys[]'";
    };
    update-ddc-plugins = mkApp {
      name = "update-ddc-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep ddc | xargs -I {} nix flake update {}
        nix flake update neco-vim
        nix flake update vim-mr
        nix flake update pum-vim
        nix flake update denops-popup-preview-vim
        nix flake update denops-signature_help
      '';
    };
    update-ddu-plugins = mkApp {
      name = "update-ddu-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep ddu | xargs -I {} nix flake update {}
      '';
    };
    update-neorg-plugins = mkApp {
      name = "update-ddu-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep neorg | xargs -I {} nix flake update {}
      '';
    };
    update-telescope-plugins = mkApp {
      name = "update-telescope-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep telescope | xargs -I {} nix flake update {}
      '';
    };
    update-neotest-plugins = mkApp {
      name = "update-telescope-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep neotest | xargs -I {} nix flake update {}
      '';
    };
  };
  devShells.default = pkgs.mkShell {
    packages = with pkgs; [
      npins
    ];
  };
}
