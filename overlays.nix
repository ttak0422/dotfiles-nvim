{ inputs, inputs' }:
with inputs;
[
  nix-filter.overlays.default
  nix-vscode-extensions.overlays.default
  (import ./jvm-runtimes.nix)
  (
    final: prev:
    let
      inherit (prev.stdenv) mkDerivation;
    in
    {
      git-gtr = final.callPackage ./nix/packages/git-gtr.nix {
        src = inputs.git-worktree-runner;
      };

      # Keep the agent compatible with the Eclipse internals in JDT LS.
      lombok = prev.lombok.overrideAttrs (_: rec {
        version = "1.18.48";
        src = prev.fetchurl {
          url = "https://projectlombok.org/downloads/lombok-${version}.jar";
          hash = "sha256-hUd6RlXrssB0qQmc+3Sb5FREn+5WTUKCYQ3xuF98UIs=";
        };
      });

      javaPackages = prev.javaPackages // {
        inherit (inputs) jol junit-console;
      };

      kotlin-lsp = mkDerivation rec {
        pname = "kotlin-lsp";
        version = "271.2085.0";
        src = final.fetchurl {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";
          hash = "sha256-LSI4j1i+b036eo8YweIxhxFk3KzBbkB1WQKdcjKBa0o=";
        };
        nativeBuildInputs = [ final.unzip ];
        unpackCmd = "unzip -q $curSrc";
        dontBuild = true;
        # Keep the signed native launcher and bundled runtime unmodified.
        dontFixup = true;
        installPhase = ''
          runHook preInstall

          # Preserve the native launcher's layout, including its bundled JBR.
          test -x bin/intellij-server
          mkdir -p "$out/libexec/kotlin-lsp" "$out/bin"
          cp -a . "$out/libexec/kotlin-lsp/"
          ln -s "$out/libexec/kotlin-lsp/bin/intellij-server" "$out/bin/kotlin-lsp"

          runHook postInstall
        '';
        # This overlay currently packages only the macOS Apple Silicon archive.
        meta.platforms = [ "aarch64-darwin" ];
      };

      inherit (inputs'.v3-mcp-hub.packages) mcp-hub;

      skk-dict = mkDerivation {
        name = "skk-dict";
        src = inputs.skk-dict;
        dontBuild = true;
        installPhase = ''
          mkdir $out
          cp SKK-JISYO.L $out/SKK-JISYO.L
        '';
      };
    }
  )
]
