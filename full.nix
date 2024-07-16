{ pkgs, ... }:
let
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (pkgs.stdenv) mkDerivation;
  read = builtins.readFile;
in
{
  v9 = {
    package = pkgs.pkgs-stable.neovim-unwrapped;
    extraPackages = [ ];
    extraConfig = read ./lua/autogen/prelude.lua;
    after = {
      plugin = { };
      ftplugin =
        let
          hashkellTools = ''
            dofile("${pkgs.vimPlugins.haskell-tools-nvim}/ftplugin/haskell.lua")
          '';
        in
        {
          gina-blame = {
            language = "vim";
            code = read ./vim/after/gina-blame.vim;
          };
          cabal = hashkellTools;
          cabalproject = hashkellTools;
          cagbal = hashkellTools;
          lhaskell = hashkellTools;
          neorg = {
            language = "vim";
            code = read ./vim/after/neorg.vim;
          };
          ddu-ff = {
            language = "vim";
            code = read ./vim/after/ddu-ff.vim;
          };
          ddu-ff-filter = {
            language = "vim";
            code = read ./vim/after/ddu-ff-filter.vim;
          };
        };
    };
    # WIP #
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
      denops = {
        package = denops-vim;
        preConfig = ''
          " use latest
          let g:denops#deno = '${pkgs.deno}/bin/deno'
          let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-kv']
        '';
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
      hookBuffer = {
        postConfig = read ./lua/autogen/hook-buffer.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      hookCmdline = {
        postConfig = read ./lua/autogen/hook-cmdline.lua;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      hookEdit = {
        postConfig = read ./lua/autogen/hook-edit.lua;
        hooks = {
          events = [
            "InsertEnter"
            "CursorMoved"
          ];
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
            dofile('${cmp-buffer}/after/plugin/cmp_buffer.lua')
            dofile('${cmp-cmdline}/after/plugin/cmp_cmdline.lua')
            dofile('${cmp-cmdline-history}/after/plugin/cmp_cmdline_history.lua')
            dofile('${cmp-nvim-lsp}/after/plugin/cmp_nvim_lsp.lua')
            dofile('${cmp-path}/after/plugin/cmp_path.lua')
            dofile('${cmp_luasnip}/after/plugin/cmp_luasnip.lua')
          ''
          + read ./lua/autogen/cmp.lua;
        hooks = {
          events = [ "LspAttach" ];
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
          climbdir-nvim
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
          events = [ "BufReadPost" ];
        };
      };
      dap = {
        packages = [
          nvim-dap
          nvim-dap-virtual-text
          nvim-dap-repl-highlights
        ];
        postConfig = read ./lua/autogen/dap.lua;
        hooks = {
          modules = [ "dap" ];
        };
      };
      dap-go = {
        package = nvim-dap-go;
        extraPackages = with pkgs; [ delve ];
        postConfig = read ./lua/autogen/dap-go.lua;
        hooks = {
          fileTypes = [ "go" ];
        };
      };
      dap-ui = {
        package = nvim-dap-ui;
        depends = [ dap ];
        postConfig = read ./lua/autogen/dap-ui.lua;
        hooks = {
          modules = [ "dap-ui" ];
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
      dd = {
        package = nvim-dd;
        postConfig = read ./lua/autogen/dd.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      autopairs = {
        package = nvim-autopairs;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/autopairs.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      ambiwidth = {
        package = vim-ambiwidth;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      asterisk = {
        package = vim-asterisk;
        postConfig = {
          language = "vim";
          code = read ./vim/asterisk.vim;
        };
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      auto-indent = {
        package = auto-indent-nvim;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/auto-indent.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      better-escape = {
        package = better-escape-nvim;
        postConfig = read ./lua/autogen/better-escape.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      bqf = {
        package = nvim-bqf;
        depends = [
          treesitter
          {
            package = nvim-pqf;
            postConfig = read ./lua/autogen/pqf.lua;
          }
        ];
        postConfig = read ./lua/autogen/bqf.lua;
        hooks = {
          events = [ "QuickFixCmdPost" ];
        };
      };
      bufdel = {
        package = nvim-bufdel;
        postConfig = read ./lua/autogen/bufdel.lua;
        hooks = {
          commands = [
            "BufDel"
            "BufDel!"
          ];
        };
      };
      codewindow = {
        package = codewindow-nvim;
        depends = [ treesitter ];
        postConfig = {
          code = read ./lua/autogen/codewindow.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
          };
        };
        hooks = {
          modules = [ "codewindow" ];
        };
      };
      colorizer = {
        package = nvim-colorizer-lua;
        postConfig = read ./lua/autogen/colorizer.lua;
        hooks = {
          commands = [ "ColorizerToggle" ];
        };
      };
      comment = {
        package = Comment-nvim;
        postConfig = read ./lua/autogen/comment.lua;
        hooks = {
          events = [
            "InsertEnter"
            "CursorMoved"
          ];
        };
      };
      context-vt = {
        package = nvim_context_vt;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/context-vt.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      detour = {
        package = detour-nvim;
        hooks = {
          commands = [
            "Detour"
            "DetourCurrentWindow"
          ];
        };
      };
      diffview = {
        package = diffview-nvim;
        depends = [ devicons ];
        hooks = {
          commands = [
            "DiffviewOpen"
            "DiffviewToggleFiles"
          ];
        };
      };
      direnv = {
        package = direnv-vim;
        postConfig = read ./lua/direnv.lua;
        hooks = {
          events = [ "DirChangedPre" ];
        };
      };
      femaco = {
        package = nvim-FeMaco-lua;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/femaco.lua;
        hooks = {
          commands = [ "FeMaco" ];
        };
      };
      leap = {
        package = leap-nvim;
        depends = [ vim-repeat ];
        postConfig = read ./lua/autogen/leap.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      flit = {
        package = flit-nvim;
        depends = [ leap ];
        postConfig = read ./lua/autogen/flit.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      flow = {
        package = flow-nvim;
        postConfig = read ./lua/autogen/flow.lua;
        hooks = {
          commands = [
            "FlowRunSelected"
            "FlowRunFile"
            "FlowLauncher"
          ];
        };
      };
      fundo = {
        package = nvim-fundo;
        depends = [ promise-async ];
        postConfig = read ./lua/autogen/fundo.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      gin = {
        package = gin-vim;
        depends = [ denops ];
        postConfig = read ./lua/autogen/gin.lua;
        hooks = {
          commands = [
            "Gin"
            "GinBuffer"
            "GinLog"
            "GinStatus"
            "GinDiff"
            "GinBrowse"
            "GinBranch"
          ];
        };
        useDenops = true;
      };
      gina = {
        package = gina-vim;
        postConfig = {
          language = "vim";
          code = read ./vim/gina.vim;
        };
      };
      git-conflict = {
        package = git-conflict-nvim;
        depends = [ plenary ];
        postConfig = read ./lua/autogen/git-conflict.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      gitsigns = {
        package = gitsigns-nvim;
        depends = [ plenary ];
        postConfig =
          ''
            require("morimo").load("gitsigns")
          ''
          + read ./lua/autogen/gitsigns.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      gopher = {
        package = gopher-nvim;
        depends = [
          plenary
          lsp
          treesitter
        ];
        postConfig = read ./lua/autogen/gopher.lua;
        extraPackages = with pkgs; [
          gomodifytags
          impl
          gotests
          iferr
          delve
        ];
        hooks = {
          fileTypes = [
            "go"
            "gomod"
          ];
        };
      };
      goto-preview = {
        package = pkgs.vimPlugins.goto-preview;
        postConfig = read ./lua/autogen/goto-preview.lua;
        hooks = {
          commands = [ "goto-preview" ];
        };
      };
      harpoon = {
        package = harpoon-2;
        depends = [ plenary ];
        postConfig = read ./lua/autogen/harpoon.lua;
        hooks = {
          modules = [ "harpoon" ];
        };
      };
      haskell-tools = {
        package = haskell-tools-nvim;
        depends = [
          plenary
          lsp
        ];
        postConfig = {
          code = read ./lua/autogen/haskell-tools.lua;
          args = {
            on_attach_path = ./lua/autogen/lsp-on-attach.lua;
            capabilities_path = ./lua/lsp-capabilities.lua;
          };
        };
        extraPackages = with pkgs; [
          ghc
          haskellPackages.fourmolu
          haskellPackages.haskell-language-server
        ];
        hooks = {
          fileTypes = [
            "cagbal"
            "cabalproject"
            "haskell"
            "lhaskell"
          ];
        };
      };
      heirline = {
        packages = [
          heirline-nvim
          # heirline-components-nvim
        ];
        depends = [
          plenary
          {
            package = scope-nvim;
            postConfig = read ./lua/autogen/scope.lua;
          }
          gitsigns
          {
            package = harpoonline;
            depends = [ harpoon ];
            postConfig = read ./lua/autogen/harpoonline.lua;
          }
          {
            package = lsp-progress-nvim;
            postConfig = read ./lua/autogen/lsp-progress.lua;
          }
        ];
        postConfig = read ./lua/heirline.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      history-ignore = {
        package = history-ignore-nvim;
        postConfig = read ./lua/autogen/history-ignore.lua;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      hlchunk = {
        package = hlchunk-nvim;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/hlchunk.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      hlslens = {
        package = nvim-hlslens;
        postConfig = read ./lua/autogen/hlslens.lua;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      hydra = {
        package = hydra-nvim;
        postConfig = read ./lua/autogen/hydra.lua;
        hooks = {
          commands = [
            "CmdlineEnter"
            "CursorMoved"
          ];
        };
      };
      img-clip = {
        package = img-clip-nvim;
        postConfig = read ./lua/autogen/img-clip.lua;
        hooks = {
          modules = [ "img-clip" ];
        };
      };
      indent-o-matic = {
        package = pkgs.vimPlugins.indent-o-matic;
        postConfig = read ./lua/autogen/indent-o-matic.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      jabs = {
        package = JABS-nvim;
        postConfig = read ./lua/autogen/jabs.lua;
        hooks = {
          commands = [ "JABSOpen" ];
        };
      };
      jdtls = {
        package = nvim-jdtls;
        # postConfig = configured in after/ftplugin/java
        depends = [
          lsp
          dap
        ];
        hooks = {
          fileTypes = [ "java" ];
        };
      };
      lastplace = {
        package = nvim-lastplace;
        preConfig = {
          code = read ./lua/autogen/lastplace-pre.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
            exclude_buf_ft_path = ./lua/autogen/exclude_buf_ft.lua;
          };
        };
        hooks = {
          events = [ "BufReadPre" ];
        };
      };
      legendary = {
        package = legendary-nvim;
        depends = [
          {
            package = sqlite-lua;
            postConfig = ''
              if has('mac')
                let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.dylib'
              else
                let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'
              endif
            '';
          }
          telescope
        ];
        postConfig = read ./lua/autogen/legendary.lua;
        hooks = {
          commands = [ "Legendary" ];
        };
      };
      markdown-preview = {
        package = markdown-preview-nvim;
        hooks = {
          filetypes = [ "markdown" ];
        };
      };
      marks = {
        package = marks-nvim;
        postConfig = read ./lua/autogen/marks.lua;
        hooks = {
          commands = [
            "MarksQFListBuf"
            "MarksQFListGlobal"
          ];
          events = [ "CursorMoved" ];
        };
      };
      mkdir = {
        package = mkdir-nvim;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      mkdnflow = {
        package = mkdnflow-nvim;
        depends = [ plenary ];
        postConfig = read ./lua/autogen/mkdnflow.lua;
        hooks = {
          filetypes = [ "markdown" ];
        };
      };
      BufferBrowser = {
        package = pkgs.vimPlugins.BufferBrowser;
        postConfig = {
          code = read ./lua/autogen/BufferBrowser.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
          };
        };
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      nap = {
        package = nap-nvim;
        depends = [ BufferBrowser ];
        postConfig = read ./lua/autogen/nap.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      neogit = {
        package = pkgs.vimPlugins.neogit;
        depends = [
          plenary
          diffview
          telescope
        ];
        extraPackages = [ pkgs.gh ];
        postConfig = read ./lua/autogen/neogit.lua;
        hooks = {
          commands = [ "Neogit" ];
        };
      };
      NeoZoom = {
        package = NeoZoom-lua;
      };
      nfnl = {
        package = pkgs.vimPlugins.nfnl;
        extraPackages = with pkgs; [
          sd
          fd
        ];
        hooks = {
          fileTypes = [ "fennel" ];
        };
      };
      notify = {
        package = nvim-notify;
        postConfig = read ./lua/autogen/notify.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      noice = {
        package = noice-nvim;
        depends = [
          nui
          notify
          treesitter
        ];
        postConfig = {
          code = read ./lua/autogen/noice.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
          };
        };
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      null-ls = {
        package = none-ls-nvim;
        depends = [ plenary ];
        extraPackages = with pkgs; [
          gofumpt
          go-tools
        ];
        postConfig = read ./lua/autogen/null-ls.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      numb = {
        package = numb-nvim;
        postConfig = read ./lua/autogen/numb.lua;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      nvim-window = {
        package = pkgs.vimPlugins.nvim-window;
        postConfig = read ./lua/autogen/nvim-window.lua;
        hooks = {
          modules = [ "nvim-window" ];
        };
      };
      octo = {
        package = pkgs.octo-nvim;
        depends = [
          plenary
          devicons
          telescope
        ];
        postConfig = read ./lua/autogen/octo.lua;
        hooks = {
          commands = [ "Octo" ];
        };
      };
      open = {
        package = open-nvim;
        postConfig = read ./lua/autogen/open.lua;
        hooks = {
          modules = [ "open" ];
        };
      };
      toggleterm = {
        package = toggleterm-nvim;
        depends = [ term-gf-nvim ];
        postConfig = read ./lua/autogen/toggleterm.lua;
        hooks = {
          commands = [
            "ToggleTerm"
            "TermToggle"
          ];
        };
      };
      project = {
        package = project-nvim;
        postConfig = read ./lua/autogen/project.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      # TODO: modify lazy loading
      overseer = {
        package = overseer-nvim;
        depends = [ toggleterm ];
        postConfig = read ./lua/autogen/overseer.lua;
        hooks = {
          commands = [ "OverseerRun" ];
        };
      };
      qf = {
        package = qf-nvim;
        postConfig = read ./lua/autogen/qf.lua;
        hooks = {
          fileTypes = [ "qf" ];
          commands = [
            "Qnext"
            "Qprev"
            "Lnext"
            "Lprev"
          ];
        };
      };
      qfreplace = {
        package = vim-qfreplace;
        hooks = {
          commands = [ "Qfreplace" ];
        };
      };
      reacher = {
        package = reacher-nvim;
        postConfig = read ./lua/autogen/reacher.lua;
        hooks = {
          modules = [ "reacher" ];
        };
      };
      registers = {
        package = registers-nvim;
        postConfig = read ./lua/autogen/registers.lua;
        hooks = {
          events = [ "CursorMoved" ];
        };
      };
      rustaceanvim = {
        package = pkgs.vimPlugins.rustaceanvim;
        depends = [
          toggleterm
          lsp
          dap
        ];
        extraPackages = with pkgs; [ graphviz ];

        preConfig = {
          code = read ./lua/autogen/rustaceanvim-pre.lua;
          args = {
            on_attach_path = ./lua/autogen/lsp-on-attach.lua;
          };
        };
        hooks = {
          modules = [ "rustaceanvim" ];
        };
      };
      skk = {
        package = skkeleton;
        depends = [ denops ];
        postConfig = {
          language = "vim";
          code = read ./vim/skk.vim;
          args = {
            jisyo = "${pkgs.skk-dicts}/share/SKK-JISYO.L";
          };
        };
        hooks = {
          events = [
            "InsertEnter"
            "CmdlineEnter"
          ];
        };
        useDenops = true;
      };
      smart-splits = {
        package = smart-splits-nvim;
        postConfig = read ./lua/autogen/smart-splits.lua;
        hooks = {
          modules = [ "smart-splits" ];
          events = [ "WinNew" ];
        };
      };
      spectre = {
        package = nvim-spectre;
        depends = [
          plenary
          devicons
        ];
        postConfig = read ./lua/autogen/spectre.lua;
        extraPackages = with pkgs; [
          gnused
          ripgrep
        ];
        hooks = {
          modules = [ "spectre" ];
        };
      };
      startuptime = {
        package = vim-startuptime;
        hooks = {
          commands = [ "StartupTime" ];
        };
      };
      statuscol = {
        package = statuscol-nvim;
        postConfig = read ./lua/autogen/statuscol.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      stickybuf = {
        package = stickybuf-nvim;
        postConfig = read ./lua/autogen/stickybuf.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      tabout = {
        package = tabout-nvim;
        depends = [ treesitter ];
        postConfig = read ./lua/autogen/tabout.lua;
        hooks = {
          events = [ "InsertEnter" ];
        };
      };
      tint = {
        package = tint-nvim;
        postConfig = read ./lua/autogen/tint.lua;
        hooks = {
          events = [ "WinNew" ];
        };
      };
      trouble = {
        package = trouble-nvim;
        depends = [ lsp ];
        postConfig = read ./lua/autogen/trouble.lua;
        hooks = {
          modules = [ "trouble" ];
          commands = [ "TroubleToggle" ];
        };
      };
      todo-comments = {
        package = todo-comments-nvim;
        depends = [
          plenary
          trouble
        ];
        extraPackages = with pkgs; [ ripgrep ];
        postConfig = read ./lua/autogen/todo-comments.lua;
        hooks = {
          # commands = [
          #   "TodoQuickFix"
          #   "TodoLocList"
          #   "TodoTrouble"
          #   "TodoTelescope"
          # ];
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      toolwindow = {
        plugin = toolwindow-nvim;
        hooks = {
          modules = [ "toolwindow" ];
        };
      };
      translate = {
        package = denops-translate-vim;
        depends = [ denops ];
        # TODO
        preConfig = "";
        hooks = {
          commands = [ "Translate" ];
        };
        useDenops = true;
      };
      trim = {
        package = trim-nvim;
        postConfig = read ./lua/autogen/trim.lua;
        hooks = {
          events = [ "BufWritePre" ];
        };
      };
      ts-autotag = {
        package = nvim-ts-autotag;
        postConfig = read ./lua/autogen/ts-autotag.lua;
        depends = [ treesitter ];
        hooks = {
          fileTypes = [
            "javascript"
            "typescript"
            "jsx"
            "tsx"
            "vue"
            "html"
          ];
        };
      };
      ufo = {
        package = nvim-ufo;
        depends = [
          promise-async
          treesitter
        ];
        postConfig = read ./lua/autogen/ufo.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      undotree = {
        package = pkgs.vimPlugins.undotree;
        preConfig = {
          language = "vim";
          code = read ./vim/undotree.vim;
        };
        hooks = {
          commands = [ "UndotreeToggle" ];
        };
      };
      venn = {
        package = venn-nvim;
        hooks = {
          commands = [ "VBox" ];
        };
      };
      vim-nix = {
        package = pkgs.vimPlugins.vim-nix;
        hooks = {
          fileTypes = [ "nix" ];
        };
      };
      vimdoc-ja = {
        package = pkgs.vimPlugins.vimdoc-ja;
        hooks = {
          events = [ "CmdlineEnter" ];
        };
      };
      vtsls = {
        package = nvim-vtsls;
        depends = [ lsp ];
        postConfig = read ./lua/autogen/vtsls.lua;
        hooks = {
          fileTypes = [
            "typescript"
            "javascript"
          ];
        };
      };
      waitevent = {
        package = waitevent-nvim;
        postConfig = read ./lua/autogen/waitevent.lua;
        hooks = {
          userEvents = [ "SpecificFileEnter" ];
        };
      };
      whichkey = {
        package = which-key-nvim;
        postConfig = read ./lua/autogen/whichkey.lua;
        hooks = {
          userEvents = [ "TriggerLeader" ];
        };
      };
      window-picker = {
        package = nvim-window-picker;
        postConfig = {
          code = read ./lua/autogen/window-picker.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
            exclude_buf_ft_path = ./lua/autogen/exclude_buf_ft.lua;
          };
        };
      };
      winsep = {
        package = colorful-winsep-nvim;
        postConfig = {
          code = read ./lua/autogen/winsep.lua;
          args = {
            exclude_ft_path = ./lua/autogen/exclude_ft.lua;
          };
        };
      };
      winshift = {
        package = winshift-nvim;
        postConfig = read ./lua/autogen/winshift.lua;
        hooks = {
          commands = [ "WinShift" ];
        };
      };
      ddu = {
        packages = [
          ddu-ui-ff
          ddu-ui-filter
          ddu-source-file
          ddu-source-file_rec
          ddu-source-rg
          ddu-source-ghq
          ddu-source-file_external
          ddu-source-mr
          ddu-filter-fzf
          ddu-filter-matcher_substring
          ddu-filter-matcher_hidden
          ddu-filter-sorter_alpha
          ddu-filter-converter_hl_dir
          # ddu-filter-converter_devicon
          ddu-filter-converter_display_word
          ddu-kind-file
          ddu-commands-vim
        ];
        depends = [
          denops
          mr-vim
        ];
        extraPackages = with pkgs; [
          ripgrep
          fd
          fzf
          ghq
        ];
        postConfig = {
          language = "vim";
          code = read ./vim/ddu.vim;
          args = {
            ts_config = ./denops/ddu.ts;
          };
        };
        hooks = {
          commands = [
            "Ddu"
            "DduRg"
            "DduRgLive"
          ];
        };
        useDenops = true;
      };
      neotest = {
        packages = [
          pkgs.vimPlugins.neotest
          neotest-java
          neotest-python
          neotest-plenary
          # neotest-go
          neotest-golang
          neotest-jest
          neotest-vitest
          neotest-playwright
          neotest-rspec
          neotest-minitest
          neotest-dart
          neotest-testthat
          neotest-phpunit
          neotest-pest
          neotest-rust
          neotest-elixir
          neotest-dotnet
          neotest-scala
          neotest-haskell
          neotest-deno
          neotest-vim-test
        ];
        depends = [
          plenary
          nio
          treesitter
          lsp
          dap
          vim-test
        ];
        postConfig = {
          code = read ./lua/autogen/neotest.lua;
          args = {
            junit_jar_path = pkgs.javaPackages.junit-console;
          };
        };
        hooks = {
          commands = [
            "Neotest"
            "NeotestNearest"
            "NeotestToggleSummary"
          ];
          modules = [ "neotest" ];
        };
      };
    };
  };
}
