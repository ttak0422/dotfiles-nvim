{ pkgs, sources }:
pkgs.buildGoModule {
  pname = "goda-skk";
  version = sources."goda-skk.vim".version;
  src = ./config;
  subPackages = [ "." ];
  # Editor scripts and compiled Go use the same unmodified upstream pins.
  postPatch = ''
    mkdir -p .deps
    cp -R ${sources."goda.vim"} .deps/goda
    cp -R ${sources."goda-skk.vim"} .deps/goda-skk
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
}
