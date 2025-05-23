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
          packages = [
            nvim-treesitter
            nvim-treesitter-textobjects
          ];
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
              package = guess-indent-nvim;
              postConfig = read "./fnl/guess-indent.fnl";
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
            typos-lsp
            vscode-langservers-extracted
          ];
        };
        none-ls = {
          package = none-ls-nvim;
          depends = [
            plenary
            none-ls-extras-nvim
            lsp
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
          none-ls
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

    inputPlugins = {
      depends = [
        {
          package = nvim-autopairs;
          depends = [ bufferPlugins ];
          postConfig = read "./fnl/autopairs.fnl";
        }
        {
          package = auto-save-nvim;
          postConfig = read "./fnl/auto-save.fnl";
        }
      ];
      hooks.events = [ "InsertEnter" ];
    };

    editPlugins = {
      depends = [
        {
          package = nvim-surround;
          depends = [ bufferPlugins ];
          postConfig = read "./fnl/surround.fnl";
        }
        {
          package = dmacro-vim;
          postConfig = {
            code = ''
              inoremap <C-q> <Plug>(dmacro-play-macro)
              nnoremap <C-q> <Plug>(dmacro-play-macro)
            '';
            language = "vim";
          };
        }
        {
          package = switch-vim;
          preConfig = {
            language = "vim";
            code = ''
              let g:switch_mapping = '-'
            '';
          };
        }
        {
          package = which-key-nvim;
          postConfig = read "./fnl/which-key.fnl";
        }
      ];
      hooks.events = [
        "InsertEnter"
        "CursorMoved"
      ];
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

    telescope = {
      packages = [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        telescope-sonictemplate-nvim
        telescope-sg
      ];
      depends = [
        plenary
        quickfixPlugins
        {
          package = vim-sonictemplate.overrideAttrs (old: {
            src = pkgs.nix-filter {
              root = vim-sonictemplate.src;
              exclude = [
                "template/java"
                "template/make"
              ];
            };
          });
          preConfig =
            let
              template = pkgs.stdenv.mkDerivation {
                pname = "sonictemplate";
                version = "custom";
                src = ./../tmpl/sonic;
                installPhase = ''
                  mkdir $out
                  cp -r ./* $out
                '';
              };
            in
            ''
              vim.g.sonictemplate_vim_template_dir = "${template}"
                           vim.g.sonictemplate_key = 0
                           vim.g.sonictemplate_intelligent_key = 0
                           vim.g.sonictemplate_postfix_key = 0
            '';
        }
      ];
      postConfig = read "./fnl/telescope.fnl";
      hooks.commands = [
        "Telescope"
        "TelescopeBuffer"
      ];
    };

    trouble = {
      package = trouble-nvim;
      depends = [
        devicons
        bufferPlugins
      ];
      postConfig = read "./fnl/trouble.fnl";
      hooks.modules = [ "trouble" ];
    };

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

    quickfixPlugins = {
      depends = [
        {
          package = nvim-bqf;
          depends = [ bufferPlugins ];
          postConfig = read "./fnl/bqf.fnl";
        }
        {
          package = qf-nvim;
          postConfig = read "./fnl/qf.fnl";
          hooks.commands = [
            "Qnext"
            "Qprev"
            "Lnext"
            "Lprev"
          ];
        }
        { package = vim-qfreplace; }
      ];
      hooks.events = [
        "QuickFixCmdPost"
        "CmdlineEnter"
      ];
    };

    commandPlugins = {
      depends = [
        {
          packages = [
            lir-nvim
            lir-git-status-nvim
          ];
          depends = [
            plenary
            devicons
          ];
          postConfig = read "./fnl/lir.fnl";
          hooks.modules = [ "lir.float" ];
        }
        {
          package = oil-nvim;
          depends = [ devicons ];
          postConfig = read "./fnl/oil.fnl";
          hooks.modules = [ "oil" ];
        }
        {
          package = capture-vim;
          hooks.commands = [ "Capture" ];
        }
        {
          package = harpoon-2;
          depends = [ plenary ];
          postConfig = read "./fnl/harpoon.fnl";
          hooks.modules = [ "harpoon" ];
        }
        {
          package = nvim-bufdel;
          postConfig = read "./fnl/bufdel.fnl";
          hooks.commands = [
            "BufDel"
            "BufDel!"
            "BufDelAll"
          ];
        }
        {
          package = detour-nvim;
          hooks.modules = [ "detour" ];
        }
      ];
    };

    cmdlinePlugins = {
      depends = [
        {
          package = helpview-nvim;
          postConfig = read "./fnl/helpview.fnl";
          depends = [ bufferPlugins ];
        }
      ];
      postConfig = read "./fnl/cmdline-plugins.fnl";
      hooks.events = [ "CmdlineEnter" ];
    };

    filetypePlugins = {
      depends = [
        {
          package = crates-nvim;
          postConfig = read "./fnl/crates.fnl";
          depends = [ bufferPlugins ];
          hooks.fileTypes = [ "toml" ];
        }
        {
          package = pkgs.vimPlugins.vim-nix;
          hooks = {
            fileTypes = [ "nix" ];
          };
        }
        {
          package = pkgs.vimPlugins.nfnl;
          extraPackages = with pkgs; [
            sd
            fd
          ];
          hooks.fileTypes = [ "fennel" ];
        }
        {
          package = nginx-vim.overrideAttrs (old: {
            src = pkgs.nix-filter {
              root = nginx-vim.src;
              exclude = [ "ftdetect/nginx.vim" ];
            };
          });
          hooks.fileTypes = [ "nginx" ];
        }
      ];
    };
  };
}
