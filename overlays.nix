{ inputs, inputs' }:
with inputs;
[
  nix-filter.overlays.default
  nix-vscode-extensions.overlays.default
  (import ./jvm-runtimes.nix)
  (
    final: prev:
    let
      inherit (builtins)
        attrNames
        listToAttrs
        getAttr
        ;
      inherit (prev.lib)
        cleanSource
        ;
      inherit (prev.stdenv) system mkDerivation;
      inherit (prev.vimUtils) buildVimPlugin;
    in
    {
      pkgs-stable = import nixpkgs-stable { inherit system; };

      # Remove this patch override when pinned nixpkgs reaches Neovim 0.12.6.
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (_: rec {
        version = "0.12.6";
        src = prev.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          tag = "v${version}";
          hash = "sha256-lK1gbJyESMN3C/i8cyPFzzlJDYZHzEXugGhCwPVEbNk=";
        };
      });

      norg-fmt = prev.rustPlatform.buildRustPackage {
        pname = "neorg-fmt";
        version = inputs.norg-fmt.rev;
        src = cleanSource inputs.norg-fmt;
        cargoLock = {
          lockFile = "${inputs.norg-fmt}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };

      # Keep the agent compatible with the Eclipse internals in JDT LS.
      lombok = prev.lombok.overrideAttrs (_: rec {
        version = "1.18.48";
        src = prev.fetchurl {
          url = "https://projectlombok.org/downloads/lombok-${version}.jar";
          hash = "sha256-hUd6RlXrssB0qQmc+3Sb5FREn+5WTUKCYQ3xuF98UIs=";
        };
      });

      jdt-language-server = (prev.jdt-language-server.override { jdk = final.jdk25; }).overrideAttrs (_: {
        version = "1.63.0";
        src = prev.fetchurl {
          url = "https://download.eclipse.org/jdtls/milestones/1.63.0/jdt-language-server-1.63.0-202610191322.tar.gz";
          hash = "sha256-sfKr4LPMy0Ys9k+0pVh8fQnfYM+L53SLFSy9idAYvcQ=";
        };
      });

      javaPackages = prev.javaPackages // {
        inherit (inputs) jol junit-console;
      };

      nodePackages = prev.nodePackages // {
      };

      vscode-extensions = prev.vscode-extensions // {
        # vscjava = prev.vscode-extensions.vscjava // {
        #   vscode-java-test = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        #     mktplcRef = {
        #       name = "vscode-java-test";
        #       publisher = "vscjava";
        #       version = "0.42.2024080609";
        #       hash = "sha256-LuI4V/LAvwzU5OgPLdErkeXmyoxTiDNMJXTNNaX7mbc=";
        #     };
        #     meta = {
        #       license = pkgs.lib.licenses.mit;
        #     };
        #   };
        # };
      };

      vimPlugins =
        let
          buildPlugin =
            sources: name: opts:
            let
              plugin = getAttr name sources;
              sanitizedName = builtins.replaceStrings [ "." ] [ "-" ] name;
            in
            {
              name = sanitizedName;
              value = buildVimPlugin (
                opts
                // {
                  version = plugin.revision;
                  pname = sanitizedName;
                  src = plugin;
                  doCheck = false;
                }
              );
            };
          buildPlugins =
            sources: (listToAttrs (map (name: buildPlugin sources name { }) (attrNames sources)));
        in
        prev.vimPlugins
        // {
          # TODO: → `v2.vimPlugins`
          v2 = (buildPlugins (import ./v2/npins)) // import ./v2/overlays.nix { inherit inputs'; } final prev;
          tests =
            buildPlugins (import ./tests/npins) // import ./tests/overlays.nix { inherit inputs'; } final prev;
        };
      # TODO: move to `/v2`
      v2 = {
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

        inherit (inputs'.v2-mcp-hub.packages) mcp-hub;
        inherit (inputs'.v2-rustowl.packages) rustowl;
      };

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
