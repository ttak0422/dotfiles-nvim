{ inputs, inputs' }:
with inputs;
[
  nix-filter.overlays.default
  nix-vscode-extensions.overlays.default
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

      norg-fmt = prev.rustPlatform.buildRustPackage {
        pname = "neorg-fmt";
        version = inputs.norg-fmt.rev;
        src = cleanSource inputs.norg-fmt;
        cargoLock = {
          lockFile = "${inputs.norg-fmt}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };

      # 一時的なピン留め: nixpkgs 追従を戻すときはこのブロックごと削除する
      lombok = prev.lombok.overrideAttrs (_: rec {
        version = "1.18.36";
        src = prev.fetchurl {
          url = "https://projectlombok.org/downloads/lombok-${version}.jar";
          hash = "sha256-c7awW2otNltwC6sI0w+U3p0zZJC8Cszlthgf70jL8Y4=";
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
          version = "263.4702.0";
          src = final.fetchzip {
            url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";
            hash = "sha256-tCzSMSy80GfxSWTahlsryuzECGZixSh2ufPFtP8bq/g=";
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
