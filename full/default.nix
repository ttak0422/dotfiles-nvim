{ pkgs, ... }:
let
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (pkgs.stdenv) mkDerivation;
  read = builtins.readFile;
in
{
  v9 = {
    package = pkgs.pkgs-stable.neovim-unwrapped;
    extraPackages = with pkgs; [ ];
    extraConfig = read ./lua/autogen/prelude.lua;
    after = {
      plugins = with pkgs.vimPlugins; {
        # cmp-XXXX plugins are loaded on load of cmp.
        cmp_buffer = "dofile('${cmp-buffer}/after/plugin/cmp_buffer.lua')";
        cmp_cmdline = "dofile('${cmp-cmdline}/after/plugin/cmp_cmdline.lua')";
        cmp_cmdline_history = "dofile('${cmp-cmdline-history}/after/plugin/cmp_cmdline_history.lua')";
        cmp_nvim_lsp = "dofile('${cmp-nvim-lsp}/after/plugin/cmp_nvim_lsp.lua')";
        cmp_path = "dofile('${cmp-path}/after/plugin/cmp_path.lua')";
        cmp_luasnip = "dofile('${cmp_luasnip}/after/plugin/cmp_luasnip.lua')";
      };
    };
    eager = with pkgs.vimPlugins; {
      morimo = {
        package = morimo;
        startupConfig = "vim.cmd([[colorscheme morimo]])";
      };
      config-local = {
        package = nvim-config-local;
        startupConfig = read ./lua/autogen/config-local.lua;
      };
    };
    lazy = with pkgs.vimPlugins; rec {
      plenary = {
        package = plenary-nvim;
      };
      nio = {
        package = nvim-nio;
      };
      nui = {
        package = nui-nvim;
      };
      hookLeader = {
        postConfig = read ./lua/autogen/hook-leader.lua;
        hooks = {
          userEvents = [ "TriggerLeader" ];
        };
      };
      hookInsert = {
        postConfig = read ./lua/autogen/hook-insert.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      devicons = {
        package = nvim-web-devicons;
        postConfig = read ./lua/autogen/devicons.lua;
      };
      treesitter = {
        packages = [ nvim-treesitter ];
        postConfig =
          let
            buildGrammar =
              { language, src }:
              mkDerivation {
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
            fsharp = buildGrammar {
              language = "fsharp";
              src = tree-sitter-fsharp;
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
                  concatStringsSep "," (
                    nvim-treesitter.withAllGrammars.dependencies
                    ++ [
                      dap-repl
                      fsharp
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
            code = ''
              require('morimo').load('treesitter')
              ${read ./lua/autogen/treesitter.lua}
            '';
            args = {
              parser = toString parserDrv;
            };
          };
        hooks = {
          events = [ "InsertEnter" ];
        };
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
          sonictemplate
        ];
        postConfig = read ./lua/autogen/telescope.lua;
        extraPackages = with pkgs; [
          # for live-grep-args
          ripgrep
          # for sg
          ast-grep
        ];
        hooks = {
          commands = [ "Telescope" ];
        };
      };
      sonictemplate = {
        package = vim-sonictemplate;
        preConfig =
          let
            template = mkDerivation {
              pname = "sonictemplate";
              version = "custom";
              src = ./tmpl/sonic;
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
      };
      cmp = {
        packages = [
          nvim-cmp
          cmp-buffer
          cmp-cmdline
          cmp-cmdline-history
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
        ];
        depends = [ LuaSnip ];
        postConfig =
          ''
            require("morimo").load("cmp")
          ''
          + read ./lua/autogen/cmp.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      neorg = {
        packages = [
          pkgs.vimPlugins.neorg
          neorg-jupyter
          neorg-templates
          neorg-telescope
          lua-utils-nvim
          pathlib-nvim
        ];
        depends = [
          plenary
          nio
          nui
          cmp
          treesitter
          telescope
        ];
        postConfig = read ./lua/autogen/neorg.lua;
        hooks = {
          commands = [ "Neorg" ];
        };
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
          ${read ./lua/autogen/lir.lua}
        '';
        hooks = {
          modules = [ "lir.float" ];
          events = [ "CmdlineEnter" ];
        };
      };
      oil = {
        packages = [
          oil-nvim
          oil-vcs-status
        ];
        depends = [ devicons ];
        postConfig = read ./lua/autogen/oil.lua;
        hooks = {
          modules = [ "oil" ];
        };
      };
      neogen = {
        package = pkgs.vimPlugins.neogen;
        depends = [
          # vim-vsnip
          LuaSnip
          treesitter
        ];
        postConfig = read ./lua/autogen/neogen.lua;
        hooks = {
          commands = [ "Neogen" ];
        };
      };
      glance = {
        package = glance-nvim;
        postConfig = read ./lua/autogen/glance.lua;
        hooks = {
          commands = [ "Glance" ];
        };
      };
      lsp = {
        packages = [ nvim-lspconfig ];
        depends = [
          {
            package = garbage-day-nvim;
            preConfig = read ./lua/autogen/garbage-day-pre.lua;
          }
          {
            package = lsp-lens-nvim;
            postConfig = read ./lua/autogen/lsp-lens.lua;
          }
          {
            package = lsp-inlayhints-nvim;
            postConfig = read ./lua/autogen/inlayhints.lua;
          }
          {
            package = diagflow-nvim;
            postConfig = read ./lua/autogen/diagflow.lua;
          }
          {
            package = dressing-nvim;
            postConfig = read ./lua/autogen/dressing.lua;
            depends = [ telescope ];
          }
          cmp
          telescope
          {
            # efm
            package = efmls-configs-nvim;
            extraPackages = with pkgs; [
              efm-langserver
              stylua
              luajitPackages.luacheck
              fnlfmt
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
            ];
          }
          { package = climbdir-nvim; }
        ];
        extraPackages = with pkgs; [
          ast-grep
          dart
          deno
          dhall-lsp-server
          fennel-ls
          flutter
          go-tools
          google-java-format
          gopls
          lua-language-server
          marksman
          nil
          nixd
          nodePackages.bash-language-server
          pyright
          nodePackages.typescript
          nodePackages.vscode-langservers-extracted
          nodePackages.yaml-language-server
          rubyPackages.solargraph
          rust-analyzer
          taplo-cli
        ];
        preConfig = read ./lua/lsp-pre.lua;
        postConfig = {
          code = read ./lua/autogen/lsp.lua;
          args = {
            capabilities_path = ./lua/lsp-capabilities.lua;
            on_attach_path = ./lua/autogen/lsp-on-attach.lua;
          };
        };
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      LuaSnip = {
        package = pkgs.vimPlugins.LuaSnip;
        postConfig = read ./lua/autogen/luasnip.lua;
      };
      treesj = {
        package = pkgs.vimPlugins.treesj;
        postConfig = read ./lua/autogen/treesj.lua;
        hooks = {
          modules = [ "treesj" ];
        };
      };
    };
  };
}
