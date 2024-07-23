{ self', pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  package = self'.packages.loaded-nvim-nightly;
  extraPackages = [ ];
  extraConfig = read ./../lua/autogen/prelude.lua;
  after = {
    inherit (callPackage ./after.nix { }) ftplugin;
  };

  eager = {
    morimo.package = pkgs.vimPlugins.morimo;
    config-local.package = pkgs.vimPlugins.nvim-config-local;
  };

  lazy = {
    inherit (callPackage ./hook.nix { })
      hookBuffer
      hookCmdline
      hookEdit
      hookInsert
      hookLeader
      ;
    inherit (callPackage ./debug.nix { }) dap dap-go dap-ui;
    inherit (callPackage ./denops.nix { })
      ddu
      denops
      gin
      skk
      translate
      ;
    inherit (callPackage ./diagnostic.nix { }) dd trouble;
    inherit (callPackage ./git.nix { })
      diffview
      gina
      git-conflict
      gitsigns
      neogit
      octo
      ;
    inherit (callPackage ./search.nix { })
      asterisk
      fzf
      hlslens
      legendary
      reacher
      telescope
      ;
  };
in
{
  inherit
    package
    extraPackages
    extraConfig
    after
    eager
    lazy
    ;
}
