{ pkgs, inputs }:
let
  goda = pkgs.vimUtils.buildVimPlugin {
    pname = "goda.vim";
    version = inputs.goda.shortRev;
    src = inputs.goda;
  };
  skk = pkgs.vimUtils.buildVimPlugin {
    pname = "goda-skk.vim";
    version = inputs.goda-skk.shortRev;
    src = inputs.goda-skk;
  };
  binary = pkgs.buildGoModule {
    pname = "goda-skk";
    version = inputs.goda-skk.shortRev;
    src = ./config;
    subPackages = [ "." ];
    # Both editor scripts and compiled Go packages use exactly the same sources.
    postPatch = ''
      mkdir -p .deps
      cp -R ${inputs.goda} .deps/goda
      cp -R ${inputs.goda-skk} .deps/goda-skk
      cat >> go.mod <<EOF
      replace github.com/Shougo/goda.vim => ./.deps/goda
      replace github.com/Shougo/goda-skk.vim => ./.deps/goda-skk
      EOF
    '';
    vendorHash = "sha256-02nf8GIV8+9SRdWuutdbRrhx1d4DEVH1RiuUwP/Ovto=";
    env.CGO_ENABLED = "0";
    ldflags = [
      "-s"
      "-w"
      "-X main.dictionary=${pkgs.skk-dict}/SKK-JISYO.L"
    ];
    meta.mainProgram = "goda-skk";
  };
in
{
  inherit goda skk binary;
}
