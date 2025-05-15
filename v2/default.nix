{ inputs', pkgs, ... }:
let
  read =
    path:
    with builtins;
    readFile (./. + (replaceStrings [ "./fnl/" ".fnl" ] [ "/lua/autogen/" ".lua" ] path));
in
{
  package = pkgs.neovim-unwrapped;

  extraPackages = with pkgs; [
    neovim-remote
    inputs'.gitu.packages.gitu
    # gitu
  ];

  extraConfig = ''
    vim.loader.enable()
    ${builtins.readFile ./lua/autogen/init.lua}
  '';

  after = {
    ftdetect = {
      nginx = {
        language = "vim";
        code = ''
          source ${pkgs.vimPlugins.nginx-vim}/ftdetect/nginx.vim
          au BufRead,BufNewFile *.nginxconf set ft=nginx
        '';
      };
    };
    ftplugin = {
      fennel = read "./fnl/after/ftplugin/fennel.fnl";
      gitcommit = read "./fnl/after/ftplugin/gitcommit.fnl";
      nix = read "./fnl/after/ftplugin/nix.fnl";
      qf = read "./fnl/after/ftplugin/qf.fnl";
      qfreplace = read "./fnl/after/ftplugin/qfreplace.fnl";
      yaml = read "./fnl/after/ftplugin/yaml.fnl";
      jproperties = read "./fnl/after/ftplugin/jproperties.fnl";
      make = read "./fnl/after/ftplugin/make.fnl";
    };
    lsp = {
      denols = read "./fnl/after/lsp/denols.fnl";
      efm = read "./fnl/after/lsp/efm.fnl";
      fennel_ls = read "./fnl/after/lsp/fennel_ls.fnl";
      lua_ls = read "./fnl/after/lsp/lua_ls.fnl";
      nil_ls = read "./fnl/after/lsp/nil_ls.fnl";
      vtsls = read "./fnl/after/lsp/vtsls.fnl";
      yamlls = read "./fnl/after/lsp/yamlls.fnl";
    };
  };

  eager = with pkgs.vimPlugins; {
    morimo.package = morimo;
    config-local.package = nvim-config-local;
  };

  lazy = with pkgs.vimPlugins; rec {
    # colorschemes
    sorairo.package = pkgs.vimPlugins.sorairo;

    # utils
    plenary.package = plenary-nvim;
    devicons = {
      package = nvim-web-devicons;
      postConfig = read "./fnl/devicons.fnl";
    };

    bufferPlugins =
      let
        treesitter = {
          package = nvim-treesitter;
          postConfig =
            let
              buildGrammar =
                { language, src }:
                pkgs.stdenv.mkDerivation {
                  inherit src;
                  pname = "custom-grammar-${language}";
                  version = "custom";
                  CFLAGS = [
                    "-Isrc"
                    "-O2"
                  ];
                  CXXFLAGS = [
                    "-Isrc"
                    "-O2"
                  ];
                  buildPhase = ''
                    if [[ -e src/scanner.cc ]]; then
                    $CXX -fPIC -c src/scanner.cc -o scanner.o $CXXFLAGS
                    elif [[ -e src/scanner.c ]]; then
                    $CC -fPIC -c src/scanner.c -o scanner.o $CFLAGS
                    fi
                    $CC -fPIC -c src/parser.c -o parser.o $CFLAGS
                    rm -rf parser
                    $CXX -shared -o parser *.o
                  '';
                  installPhase = ''
                    mkdir -p $out/parser
                    mv parser $out/parser/${language}.so
                  '';
                };
              dap-repl = buildGrammar {
                language = "dap_repl";
                src = nvim-dap-repl-highlights;
              };
              norg-meta = buildGrammar {
                language = "norg_meta";
                src = tree-sitter-norg-meta;
              };
              parserDrv = pkgs.stdenv.mkDerivation {
                name = "treesitter-custom-grammars";
                buildCommand = ''
                  mkdir -p $out/parser
                  echo "${
                    pkgs.lib.strings.concatStringsSep "," (
                      nvim-treesitter.withAllGrammars.dependencies
                      ++ [
                        dap-repl
                        norg-meta
                      ]
                    )
                  }" \
                  | tr ',' '\n' \
                  | xargs -I {} find {} -not -type d -name '*.so' \
                  | xargs -I {} ln -s {} $out/parser
                '';
              };
            in
            {
              # TODO: add support for custom grammars
              code = read "./fnl/treesitter.fnl";
              args.parser = toString parserDrv;
            };
        };
        lsp = {
          packages = [
            nvim-lspconfig
            nvim-dd
            garbage-day-nvim
            # lsp-lens-nvim
            tiny-inline-diagnostic-nvim
          ];
          depends = [
            {
              package = efmls-configs-nvim;
              extraPackages = with pkgs; [
                efm-langserver
                stylua
                luajitPackages.luacheck
                # fnlfmt
                nodePackages.prettier
                nodePackages.eslint
                nodePackages.fixjson
                shfmt
                taplo
                yamllint
                statix
                nixfmt-rfc-style
                google-java-format
                stylelint
                vim-vint
                yapf
                pylint
                shellcheck
                rustfmt
                gitlint
                hadolint
                vtsls
              ];
            }
            {
              package = none-ls-nvim;
              depends = [
                plenary
                none-ls-extras-nvim
              ];
              extraPackages =
                with pkgs;
                # diagnostics
                [
                  actionlint # GitHub Actions
                  checkmake # Makefile
                  checkstyle # Java
                  deadnix # Nix
                  dotenv-linter # .env
                  editorconfig-checker # .editorconfig
                  gitlint # Git
                  hadolint # Dockerfile
                  ktlint # Kotlin
                  selene # Lua
                  go-tools # Go (staticcheck)
                  statix # Nix
                  stylelint # CSS, SCSS, LESS, SASS
                  vim-vint # Vim script
                  yamllint # YAML
                ]
                ++
                  # formatters
                  [
                    biome # WEB
                    fantomas # F#
                    fnlfmt # Fennel
                    gofumpt # Go
                    go-tools # Go
                    google-java-format # Java
                    ktlint # Kotlin
                    nixfmt-rfc-style # Nix
                    nodePackages.prettier # JS, TS, ...
                    shfmt # shell
                    stylelint # CSS, SCSS, LESS, SASS
                    stylua # Lua
                    html-tidy # HTML
                    yapf # Python
                  ];
              postConfig = read "./fnl/none-ls.fnl";
            }
          ];
          postConfig = read "./fnl/lsp.fnl";
          extraPackages = with pkgs; [
            ast-grep
            dart
            deno
            dhall-lsp-server
            fennel-ls
            flutter
            go
            go-tools
            google-java-format
            gopls
            kotlin-language-server
            lua-language-server
            marksman
            nil
            nixd
            nodePackages.bash-language-server
            nodePackages.typescript
            nodePackages.yaml-language-server
            pyright
            rubyPackages.solargraph
            rust-analyzer
            taplo-cli
            vscode-langservers-extracted
          ];
        };
        complete-blink = {
          packages = [ blink-cmp ];
          postConfig = ''
            -- TODO: support linux
            package.cpath = package.cpath .. ';${inputs'.blink-cmp.packages.blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.dylib'
            ${read "./fnl/blink.fnl"}
          '';
        };
      in
      {
        depends = [
          treesitter
          lsp
          complete-blink
          {
            package = bufferline-nvim;
            depends = [
              {
                package = scope-nvim;
                postConfig = read "./fnl/scope.fnl";
              }
            ];
            postConfig = read "./fnl/bufferline.fnl";
          }
          {
            package = nap-nvim;
            depends = [
              vim-bufsurf
            ];
            postConfig = read "./fnl/nap.fnl";
          }
        ];
        hooks.events = [ "BufReadPost" ];
      };

    togglePlugins = {
      package = pkgs.vimPlugins.toggler;
      extraPackages = with pkgs; [
        (writeShellApplication {
          name = "tmux";
          runtimeInputs = [ ];
          text = ''${tmux}/bin/tmux -f ${writeText "tmux.conf" ''
            set -g status off
            set -g update-environment "NVIM "

            # keymaps
            bind r source-file ${placeholder "out"} \; display-message "Reload!"

            # plugins
            run-shell ${tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
            run-shell ${tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
          ''} "$@"'';
        })
      ];
      postConfig = read "./fnl/toggle-plugins.fnl";
      hooks.modules = [ "toggler" ];
    };

    toggleterm = {
      package = toggleterm-nvim;
      depends = [
        term-gf-nvim
      ];
      postConfig = read "./fnl/toggleterm.fnl";
      hooks.modules = [ "toggleterm.terminal" ];
    };

    lir = {
      packages = [
        lir-nvim
        lir-git-status-nvim
      ];
      depends = [
        plenary
        devicons
      ];
      postConfig = ''
        require("morimo").load("lir")
        ${read "./fnl/lir.fnl"}
      '';
      hooks.modules = [ "lir.float" ];
    };

    oil = {
      package = oil-nvim;
      depends = [ devicons ];
      postConfig = read "./fnl/oil.fnl";
      hooks.modules = [ "oil" ];
    };
    capture = {
      package = capture-vim;
      hooks.commands = [ "Capture" ];
    };

    # filetype plugins
    stickybuf = {
      package = stickybuf-nvim;
      postConfig = read "./fnl/buffer-plugins.fnl";
      hooks.fileTypes = [
        "aerial"
        "dap-*"
        "dapui_*"
        "help"
        "qf"
        "toggleterm"
      ];
    };
    vim-nix = {
      package = pkgs.vimPlugins.vim-nix;
      hooks = {
        fileTypes = [ "nix" ];
      };
    };
    nfnl = {
      package = pkgs.vimPlugins.nfnl;
      extraPackages = with pkgs; [
        sd
        fd
      ];
      hooks.fileTypes = [ "fennel" ];
    };
    nginx = {
      package = nginx-vim.overrideAttrs (old: {
        src = pkgs.nix-filter {
          root = nginx-vim.src;
          exclude = [ "ftdetect/nginx.vim" ];
        };
      });
      hooks.fileTypes = [ "nginx" ];
    };
  };
}
