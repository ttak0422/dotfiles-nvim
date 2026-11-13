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
        version = "263.7084.0";
        src = final.fetchzip {
          url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";
          hash = "sha256-wD4BU8Be6pLOmrnaojm7EHr+lfYAp5NjCoPC+M3deHM=";
          extension = "zip";
        };
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall

          # Preserve the native launcher's layout, including its bundled JBR.
          mkdir -p "$out/libexec" "$out/bin"
          ln -s "$src" "$out/libexec/kotlin-lsp"
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
