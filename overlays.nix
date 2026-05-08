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
          version = "262.4739.0";
          src = final.fetchzip {
            url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-server-${version}-aarch64.sit";
            hash = "sha256-/Wzvp0vbw8UQfCsHcT5SPLFYxo5clMy86Iy3uGDPOYQ=";
            extension = "zip";
          };
          dontBuild = true;
          nativeBuildInputs = with final; [ makeWrapper ];
          buildInputs = with final; [ openjdk ];
          installPhase = ''
            runHook preInstall

            mkdir -p $out/libexec/kotlin-lsp
            for x in $src/*; do
              ln -s "$x" "$out/libexec/kotlin-lsp/$(basename "$x")"
            done

            runHook postInstall
          '';
          postFixup = ''
            wrapProgram $out/libexec/kotlin-lsp/kotlin-lsp.sh --set-default JAVA_HOME ${final.openjdk}
          '';
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
