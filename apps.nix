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
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep ddc | xargs -I {} nix flake lock --update-input {}
        nix flake lock --update-input neco-vim
        nix flake lock --update-input vim-mr
        nix flake lock --update-input pum-vim
      '';
    };
    update-ddu-plugins = mkApp {
      name = "update-ddu-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep ddu | xargs -I {} nix flake lock --update-input {}
      '';
    };
    update-neorg-plugins = mkApp {
      name = "update-ddu-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep neorg | xargs -I {} nix flake lock --update-input {}
      '';
    };
    update-telescope-plugins = mkApp {
      name = "update-telescope-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep telescope | xargs -I {} nix flake lock --update-input {}
      '';
    };
    update-neotest-plugins = mkApp {
      name = "update-telescope-plugins";
      inputs = with pkgs; [
        jq
        coreutils
      ];
      script = ''
        nix flake metadata --json | jq -r '.locks.nodes | keys[]' | grep neotest | xargs -I {} nix flake lock --update-input {}
      '';
    };
  };
}
