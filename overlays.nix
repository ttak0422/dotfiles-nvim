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
      inherit (prev) writeShellApplication writeText fetchzip;
    in
    {
      pkgs-stable = import nixpkgs-stable { inherit system; };

      v2-tmux = writeShellApplication {
        name = "tmux";
        runtimeInputs = [ ];
        text = ''${prev.tmux}/bin/tmux -f ${writeText "tmux.conf" ''
          set -g status off
          set -g update-environment "NVIM"

          # options
          set-option -g update-environment "PATH"
          set-option -g default-terminal "xterm-256color"
          set-option -ga terminal-overrides ",xterm-256color:RGB"
          set-window-option -g mode-keys vi

          # keymaps
          bind r source-file ${placeholder "out"} \; display-message "Reload!"
          bind | split-window -h
          bind - split-window -v
          bind z resize-pane -Z
          bind -r H resize-pane -L 5
          bind -r J resize-pane -D 5
          bind -r K resize-pane -U 5
          bind -r L resize-pane -R 5
          bind -r h select-pane -L
          bind -r j select-pane -D
          bind -r k select-pane -U
          bind -r l select-pane -R

          # plugins
          run-shell ${prev.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
          run-shell ${prev.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
        ''} "$@"'';
      };

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
          tests = buildPlugins (import ./tests/npins) // import ./tests/overlays.nix { inherit inputs'; } final prev;
        };
      # TODO: move to `/v2`
      v2 = {
        # https://github.com/JetBrains/homebrew-utils/blob/master/Formula/kotlin-lsp.rb
        kotlin-lsp = mkDerivation rec {
          pname = "kotlin-lsp";
          version = "0.253.10629";
          src = fetchzip {
            url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-${version}.zip";
            hash = "sha256-LCLGo3Q8/4TYI7z50UdXAbtPNgzFYtmUY/kzo2JCln0=";
            stripRoot = false;
          };
          dontBuild = true;
          nativeBuildInputs = with final; [ makeWrapper ];
          buildInputs = with final; [
            openjdk
            gradle
          ];
          installPhase = ''
            mkdir -p $out/libexec/kotlin-lsp $out/bin
            cp kotlin-lsp.sh $out/libexec/kotlin-lsp/
            cp -r lib native $out/libexec/kotlin-lsp/
          '';
          postFixup = ''
            makeWrapper ${final.bash}/bin/bash $out/bin/kotlin-lsp \
              --chdir $out/libexec/kotlin-lsp \
              --add-flags ./kotlin-lsp.sh \
              --set-default JAVA_HOME ${final.openjdk}
          '';
        };

        nodePackages = {
          inherit (inputs'.v2-mcp-hub.packages) mcp-hub;
        };

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
