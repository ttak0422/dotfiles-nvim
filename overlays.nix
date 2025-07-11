inputs: with inputs; [
  nix-filter.overlays.default
  nix-vscode-extensions.overlays.default
  nixpkgs-neorg-overlay.overlays.default
  # neovim-nightly-overlay.overlays.default
  (
    final: prev:
    let
      inherit (builtins)
        filter
        elem
        attrNames
        listToAttrs
        getAttr
        ;
      inherit (prev.lib) optionalString cleanSource;
      inherit (prev.stdenv) system isDarwin mkDerivation;
      inherit (prev.vimUtils) buildVimPlugin;
      excludeInputs = [
        "self"
        "nixpkgs"
        "nixpkgs-stable"
        "systems"
        "flake-parts"
        "nix-filter"
        "bundler"
        "junit-console"
        "jol"
        "skk-dict"
        "ctags-lsp"
      ];
      plugins = filter (name: !(elem name excludeInputs)) (attrNames inputs);
      base = {
        version = "overlay";
      };
    in
    {
      pkgs-stable = import nixpkgs-stable { inherit system; };
      pkgs-nightly = import nixpkgs-nightly { inherit system; };

      norg-fmt = prev.rustPlatform.buildRustPackage {
        pname = "neorg-fmt";
        version = inputs.norg-fmt.rev;
        src = cleanSource inputs.norg-fmt;
        cargoLock = {
          lockFile = "${inputs.norg-fmt}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };

      # buildNpmPackage (finalAttrs: {
      #   pname = "flood";
      #   version = "4.7.0";
      #
      #   src = fetchFromGitHub {
      #     owner = "jesec";
      #     repo = "flood";
      #     tag = "v${finalAttrs.version}";
      #     hash = "sha256-BR+ZGkBBfd0dSQqAvujsbgsEPFYw/ThrylxUbOksYxM=";
      #   };
      #
      #   npmDepsHash = "sha256-tuEfyePwlOy2/mOPdXbqJskO6IowvAP4DWg8xSZwbJw=";
      #
      #   # The prepack script runs the build script, which we'd rather do in the build phase.
      #   npmPackFlags = [ "--ignore-scripts" ];
      #
      #   NODE_OPTIONS = "--openssl-legacy-provider";
      #
      #   meta = {
      #     description = "Modern web UI for various torrent clients with a Node.js backend and React frontend";
      #     homepage = "https://flood.js.org";
      #     license = lib.licenses.gpl3Only;
      #     maintainers = with lib.maintainers; [ winter ];
      #   };
      # })

      javaPackages = prev.javaPackages // {
        inherit (inputs) jol junit-console;
      };

      nodePackages = prev.nodePackages // {
        mcp-hub = final.buildNpmPackage {
          pname = "mcp-hub";
          version = inputs.mcp-hub.rev;
          src = cleanSource inputs.mcp-hub;
          npmDepsHash = "sha256-7SDNbWsolCyp3bxscCEQ/ExBk8ExR4fNRzc8eVwNFq4";
        };
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
        prev.vimPlugins
        // (listToAttrs (
          map (name: {
            inherit name;
            value = buildVimPlugin {
              version = (getAttr name inputs).rev or "latest";
              pname = name;
              src = getAttr name inputs;
              doCheck = false;
            };
          }) plugins
        ))
        // {
          telescope-fzf-native-nvim = buildVimPlugin (
            base
            // {
              pname = "telescope-fzf-native-nvim";
              src = inputs.telescope-fzf-native-nvim;
              buildPhase = "make";
            }
          );
          vim-sonictemplate = buildVimPlugin (
            base
            // {
              pname = "vim-sonictemplate";
              src = prev.nix-filter {
                root = inputs.vim-sonictemplate;
                exclude = [
                  "template/java"
                  "template/make"
                ];
              };
            }
          );
          LuaSnip = buildVimPlugin (
            base
            // {
              pname = "LuaSnip";
              src = inputs.LuaSnip;
              nativeBuildInputs = [ prev.gcc ];
              buildPhase = ''
                ${optionalString isDarwin "LUA_LDLIBS='-undefined dynamic_lookup -all_load'"}
                JSREGEXP_PATH=deps/jsregexp
                make "INCLUDE_DIR=-I $PWD/deps/lua51_include" LDLIBS="$LUA_LDLIBS" -C $JSREGEXP_PATH
                cp $JSREGEXP_PATH/jsregexp.so lua/luasnip-jsregexp.so
              '';
            }
          );
        };
      gin-vim = buildVimPlugin (
        base
        // {
          pname = "gin-vim";
          src = inputs.gin-vim;
          dontPatchShebangs = true;
          postInstall = ''
            substituteInPlace \
            $out/denops/gin/proxy/editor.ts \
            $out/denops/gin/proxy/askpass.ts \
            --replace "/usr/bin/env -S deno" "${prev.deno}/bin/deno"
          '';
        }
      );

      skk-dict = mkDerivation {
        name = "skk-dict";
        src = inputs.skk-dict;
        dontBuild = true;
        installPhase = ''
          mkdir $out
          cp SKK-JISYO.L $out/SKK-JISYO.L
        '';
      };

      ctags-lsp = prev.buildGoModule {
        src = inputs.ctags-lsp;
        pname = "ctags-lsp";
        version = inputs.ctags-lsp.rev;
        vendorHash = null;
      };

      inherit (blink-cmp.packages) blink-cmp;
    }
  )
]
