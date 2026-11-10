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
  vendorHash = "sha256-kn6Z6MBjprv4R0DATvaGstGwo8PNbbObYRUWy1EMIgM=";
  env.CGO_ENABLED = "0";
  ldflags = [
    "-s"
    "-w"
    "-X main.dictionary=${pkgs.skk-dict}/SKK-JISYO.L"
    "-X main.lsof=${pkgs.lsof}/bin/lsof"
  ];
  meta.mainProgram = "goda-skk";
}
