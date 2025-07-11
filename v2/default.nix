{
  inputs',
  pkgs,
  lib,
  ...
}:
let
  read =
    path:
    with builtins;
    readFile (
      ./. + (replaceStrings [ "./fnl/" "./lua/" ".fnl" ] [ "/lua/autogen/" "/lua/" ".lua" ] path)
    );
in
{
  package = pkgs.neovim-unwrapped;

  extraPackages = with pkgs; [
    neovim-remote
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
      Avante = read "./fnl/after/ftplugin/avante.fnl";
      fennel = read "./fnl/after/ftplugin/fennel.fnl";
      gitcommit = read "./fnl/after/ftplugin/gitcommit.fnl";
      java = {
        code = read "./fnl/after/ftplugin/java.fnl";
        args =
          let
            inherit (pkgs.vscode-marketplace.vscjava) vscode-java-debug vscode-java-test;
            jdtls = pkgs.jdt-language-server;
          in
          {
            jdk8_path = "${pkgs.jdk8}";
            jdk11_path = "${pkgs.jdk11}";
            jdk17_path = "${pkgs.jdk17}";
            jdk21_path = "${pkgs.jdk}";
            jdk23_path = "${pkgs.jdk23}";
            java_path = "${pkgs.jdk}/bin/java";
            jdtls_jar_pattern = "${jdtls}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar";
            jdtls_config_path = "${jdtls}/share/java/jdtls/${
              if pkgs.stdenv.isDarwin then "config_mac" else "config_linux"
            }";
            java_debug_jar_pattern = "${vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
            java_test_jar_pattern = "${vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";
            jol_jar_path = pkgs.javaPackages.jol;
            lombok_jar_path = "${pkgs.lombok}/share/java/lombok.jar";
            vscode_spring_boot_path = "${pkgs.vscode-marketplace.vmware.vscode-spring-boot}/share/vscode/extensions/vmware.vscode-spring-boot";
          };
      };
      jproperties = read "./fnl/after/ftplugin/jproperties.fnl";
      make = read "./fnl/after/ftplugin/make.fnl";
      markdown = read "./fnl/after/ftplugin/markdown.fnl";
      nix = read "./fnl/after/ftplugin/nix.fnl";
      norg = read "./fnl/after/ftplugin/norg.fnl";
      qf = read "./fnl/after/ftplugin/qf.fnl";
      qfreplace = read "./fnl/after/ftplugin/qfreplace.fnl";
      yaml = read "./fnl/after/ftplugin/yaml.fnl";
    };
    lsp = {
      denols = read "./fnl/after/lsp/denols.fnl";
      efm = read "./fnl/after/lsp/efm.fnl";
      fennel_ls = read "./fnl/after/lsp/fennel_ls.fnl";
      lua_ls = read "./fnl/after/lsp/lua_ls.fnl";
      nil_ls = read "./fnl/after/lsp/nil_ls.fnl";
      typos_lsp = read "./fnl/after/lsp/typos_lsp.fnl";
      vtsls = read "./fnl/after/lsp/vtsls.fnl";
      yamlls = read "./fnl/after/lsp/yamlls.fnl";
    };
  };

  eager = with pkgs.vimPlugins; {
    morimo.package = morimo;
    config-local.package = nvim-config-local;
    treesitter = {
      packages = [
        nvim-treesitter
        nvim-treesitter-textobjects
        nvim-ts-context-commentstring
      ];
      startupConfig =
        let
          inherit (pkgs.tree-sitter) buildGrammar version;
          inherit (inputs'.norg.packages)
            tree-sitter-norg
            ;
          inherit (inputs'.norg-meta.packages)
            tree-sitter-norg-meta
            ;

          dap-repl = buildGrammar {
            inherit version;
            language = "dap_repl";
            src = nvim-dap-repl-highlights;
          };

          parserDrv = pkgs.stdenv.mkDerivation {
            name = "treesitter-custom-grammars";
            buildCommand = ''
              mkdir -p $out/parser
              echo "${pkgs.lib.strings.concatStringsSep "," nvim-treesitter.withAllGrammars.dependencies}" \
              | tr ',' '\n' \
              | xargs -I {} find {} -not -type d -name '*.so' \
              | xargs -I {} ln -sf {} $out/parser
              ln -s ${dap-repl}/parser $out/parser/dap_repl.so
              # overwrite norg parser
              ln -sf ${tree-sitter-norg}/parser $out/parser/norg.so
              ln -s ${tree-sitter-norg-meta}/parser $out/parser/norg-meta.so
            '';
          };
        in
        {
          # TODO: add support for custom grammars
          code = read "./fnl/treesitter.fnl";
          args.parser = toString parserDrv;
        };
    };
    lsp0 = {
      package = nvim-lspconfig;
      startupConfig = read "./fnl/lsp.fnl";
      extraPackages = with pkgs; [
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
  };

  lazy = with pkgs.vimPlugins; rec {
    # colorschemes
    sorairo.package = pkgs.vimPlugins.sorairo;

    # utils
    plenary.package = plenary-nvim;
    nui.package = nui-nvim;
    nio.package = nvim-nio;
    devicons = {
      package = nvim-web-devicons;
      postConfig = read "./fnl/devicons.fnl";
    };
    denops = {
      package = denops-vim;
      preConfig = {
        language = "vim";
        code = ''
          let g:denops#deno = '${pkgs.deno}/bin/deno'
          let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-kv']
        '';
      };
    };
    snacks = {
      package = snacks-nvim;
      postConfig = read "./fnl/snacks.fnl";
    };
    dressing = {
      package = dressing-nvim;
      postConfig = read "./fnl/dressing.fnl";
      depends = [ telescope ];
    };

    project = {
      package = project-nvim;
      postConfig = read "./fnl/project.fnl";
      hooks.commands = [ "Telescope" ];
    };

    render-markdown = {
      package = render-markdown-nvim;
      depends = [
        devicons
        # 循環参照になるため
        # blink
      ];
      postConfig = read "./fnl/render-markdown.fnl";
      hooks.fileTypes = [
        "markdown"
      ];
    };

    copilot = {
      package = copilot-lua;
      extraPackages = with pkgs; [ nodejs ];
      postConfig = read "./fnl/copilot.fnl";
    };

    avante = {
      package = pkgs.pkgs-nightly.vimPlugins.avante-nvim.overrideAttrs {
        dependencies = [ ];
        doCheck = false;
      };
      depends = [
        plenary
        nui
        render-markdown
        copilot
        dressing
        mcphub
      ];
      postConfig = read "./fnl/avante.fnl";
    };

    mcphub = {
      package = mcphub-nvim;
      depends = [
        plenary
      ];
      extraPackages = with pkgs; [
        nodejs
        nodePackages.mcp-hub
        uv
      ];
      postConfig = read "./fnl/mcphub.fnl";
    };

    blink = {
      packages = [
        blink-cmp
        blink-cmp-avante
        blink-compat
      ];
      depends = [
        luasnip
        avante
        # obsidian
      ];
      postConfig = ''
        -- TODO: support linux
        package.cpath = package.cpath .. ';${inputs'.blink-cmp.packages.blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.dylib'
        ${read "./fnl/blink.fnl"}
      '';
      hooks.modules = [ "blink.cmp" ];
    };

    luasnip = {
      package = LuaSnip;
      postConfig = read "./fnl/luasnip.fnl";
    };

    notify = {
      package = nvim-notify;
      postConfig = read "./fnl/notify.fnl";
    };

    noice = {
      package = noice-nvim;
      depends = [
        snacks
        nui
        telescope
        lsp
        notify
      ];
      postConfig = read "./fnl/noice.fnl";
      hooks.events = [
        "BufReadPost"
        "CmdlineEnter"
      ];
    };

    # TODO: refactor
    lsp = {
      packages = [
        nvim-dd
        garbage-day-nvim
        # lsp-lens-nvim
        tiny-inline-diagnostic-nvim
      ];
    };

    dap = {
      packages = [
        nvim-dap
        nvim-dap-virtual-text
        nvim-dap-repl-highlights
      ];
      postConfig = read "./fnl/dap.fnl";
      hooks.modules = [ "dap" ];
    };

    dap-ui = {
      package = nvim-dap-ui;
      depends = [
        dap
        nio
        devicons
      ];
      postConfig = read "./fnl/dap-ui.fnl";
      hooks.modules = [
        "dapui"
        "dapui.windows"
      ];
    };

    gopher = {
      package = gopher-nvim;
      postConfig = read "./fnl/gopher.fnl";
      extraPackages = with pkgs; [
        go
        gomodifytags
        gotests
        iferr
        impl
      ];
      depends = [
        lsp
        {
          package = goplements-nvim;
          postConfig = read "./fnl/goplements.fnl";
        }
        {
          package = go-impl-nvim;
          postConfig = read "./fnl/go-impl.fnl";
          depends = [
            nui
            plenary
            snacks
          ];
        }
      ];
      hooks.fileTypes = [
        "go"
        "gomod"
      ];
    };

    # TODO:
    # haskell-tools = { package = haskell-tools-nvim; };

    # TODO:
    # rustaceanvim = { package = rustaceanvim; };
    # crates = { package = crates-nvim; };

    # TODO:
    # vtsls = { package = vtsls-nvim; };

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
          go-tools # Go (staticcheck)
          hadolint # Dockerfile
          ktlint # Kotlin
          selene # Lua
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
            go-tools # Go
            gofumpt # Go
            google-java-format # Java
            html-tidy # HTML
            ktlint # Kotlin
            nixfmt-rfc-style # Nix
            nodePackages.prettier # JS, TS, ...
            shfmt # shell
            stylelint # CSS, SCSS, LESS, SASS
            stylua # Lua
            yamlfmt # YAML
            yapf # Python
          ];
      postConfig = read "./fnl/none-ls.fnl";
    };

    bufferPlugins = {
      depends = [
        lsp
        none-ls
        vim-ambiwidth
        {
          package = nvim_context_vt;
          postConfig = read "./fnl/context-vt.fnl";
        }
        {
          package = git-conflict-nvim;
          postConfig = read "./fnl/git-conflict.fnl";
        }
        {
          package = stickybuf-nvim;
          postConfig = read "./fnl/stickybuf.fnl";
        }
        {
          package = dropbar-nvim;
          postConfig = read "./fnl/dropbar.fnl";
          depends = [
            lsp
          ];
        }
        {
          package = heirline-nvim;
          postConfig = read "./lua/heirline.lua";
          depends = [
            {
              package = gitsigns-nvim;
              postConfig = read "./fnl/gitsigns.fnl";
            }
            {
              package = lsp-progress-nvim;
              postConfig = read "./fnl/lsp-progress.fnl";
            }
          ];
        }
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
        {
          package = nvim-fundo;
          depends = [ promise-async ];
          postConfig = read "./fnl/fundo.fnl";
        }
        {
          package = todo-comments-nvim;
          depends = [
            plenary
            devicons
            trouble
          ];
          postConfig = read "./fnl/todo-comments.fnl";
          extraPackages = with pkgs; [ ripgrep ];
        }
        {
          package = fix-auto-scroll-nvim;
          postConfig = ''
            require('fix-auto-scroll').setup()
          '';
        }
        {
          package = statuscol-nvim;
          postConfig = read "./fnl/statuscol.fnl";
        }
        {
          package = nvim-ufo;
          depends = [
            promise-async
          ];
          postConfig = read "./fnl/ufo.fnl";
        }
      ];
      postConfig = read "./fnl/buffer-plugins.fnl";
      hooks.events = [ "BufReadPost" ];
    };
    preBufferPlugins = {
      depends = [
        {
          package = git-conflict-nvim;
          postConfig = read "./fnl/git-conflict.fnl";
        }
        {
          package = vim-lastplace;
          preConfig = {
            language = "vim";
            code = ''
              let g:lastplace_ignore = "gitcommit,gitrebase,undotree,gitsigns-blame"
              let g:lastplace_ignore_buftype = "help,nofile,quickfix"
            '';
          };
        }
        {
          package = guess-indent-nvim;
          postConfig = read "./fnl/guess-indent.fnl";
        }
        {
          package = diffview-nvim;
          postConfig = read "./fnl/diffview.fnl";
        }
      ];
      preConfig = read "./fnl/pre-buffer-plugins-pre.fnl";
      hooks.events = [ "BufReadPre" ];
    };

    inputPlugins = {
      depends = [
        copilot
        blink
        {
          package = Comment-nvim;
          postConfig = read "./fnl/comment.fnl";
        }
        {
          package = tabout-nvim;
          postConfig = read "./fnl/tabout.fnl";
        }
        {
          package = autoclose-nvim;
          postConfig = read "./fnl/autoclose.fnl";
        }
        {
          package = auto-save-nvim;
          postConfig = read "./fnl/auto-save.fnl";
        }
        {
          package = skkeleton;
          depends = [ denops ];
          postConfig = ''
            local active_server = vim.system({"lsof", "-i", "tcp:1178"}):wait().stdout:match("yaskkserv") ~= nil
            if active_server then
              vim.fn["skkeleton#config"]({
                sources = { "skk_server" },
                globalDictionaries = { "${pkgs.skk-dict}/SKK-JISYO.L" },
                skkServerHost       = "127.0.0.1",
                skkServerPort       = 1178,
                markerHenkan        = "",
                markerHenkanSelect  = "",
              })
            else
              vim.fn["skkeleton#config"]({
                sources = { "skk_dictionary" },
                globalDictionaries = { "${pkgs.skk-dict}/SKK-JISYO.L" },
                markerHenkan        = "",
                markerHenkanSelect  = "",
              })
            end

            vim.keymap.set("i", "<C-j>", "<Plug>(skkeleton-enable)", { silent = true })
            vim.keymap.set("c", "<C-j>", "<Plug>(skkeleton-enable)", { silent = true })
            vim.keymap.set("t", "<C-j>", "<Plug>(skkeleton-enable)", { silent = true })
          '';
          useDenops = true;
        }
      ];
      hooks.events = [
        "InsertEnter"
        "CmdlineEnter"
      ];
    };

    editPlugins = {
      depends = [
        {
          package = trim-nvim;
          postConfig = read "./fnl/trim.fnl";
        }
        {
          package = hlchunk-nvim;
          postConfig = read "./fnl/hlchunk.fnl";
        }
        {
          package = better-escape-nvim;
          postConfig = read "./fnl/better-escape.fnl";
        }
        {
          package = nvim-surround;
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
        {
          packages = [
            leap-nvim
            leap-spooky-nvim
          ];
          depends = [ vim-repeat ];
          postConfig = read "./fnl/leap.fnl";
        }
        {
          package = flit-nvim;
          depends = [ vim-repeat ];
          postConfig = read "./fnl/flit.fnl";
        }
        {
          package = lasterisk-nvim;
          depends = [
            {
              package = nvim-hlslens;
              postConfig = ''
                require("hlslens").setup()
              '';
            }
          ];
          postConfig = read "./fnl/lasterisk.fnl";
        }
        {
          package = marks-nvim;
          postConfig = read "./fnl/marks.fnl";
        }
      ];
      postConfig =
        ''
          vim.cmd([[source ${./vim/edit-plugins.vim}]])
        ''
        + read "./fnl/edit-plugins.fnl";
      hooks.events = [
        "InsertEnter"
        "CmdlineEnter"
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
      depends = [ term-gf-nvim ];
      postConfig = read "./fnl/toggleterm.fnl";
      hooks.modules = [ "toggleterm.terminal" ];
    };

    telescope = {
      packages = [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        telescope-sonictemplate-nvim
      ];
      depends = [
        plenary
        quickfixPlugins
        project
        {
          package = vim-sonictemplate.overrideAttrs (_: {
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
      extraPackages = with pkgs; [ ripgrep ];
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
      ];
      postConfig = read "./fnl/trouble.fnl";
      hooks.modules = [ "trouble" ];
    };

    obsidian = {
      package = obsidian-nvim;
      depends = [
        plenary
        lsp
        telescope
        blink
      ];
      extraPackages = with pkgs; [ pngpaste ];
      postConfig = read "./fnl/obsidian.fnl";
      hooks.commands = [
        "Obsidian"
      ];
    };

    quickfixPlugins = {
      depends = [
        {
          package = nvim-bqf;
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

    modulePlugins = {
      depends = [
        {
          package = nvim-spectre;
          depends = [
            devicons
            plenary
          ];
          postConfig = read "./fnl/spectre.fnl";
          extraPackages = with pkgs; [
            ripgrep
            sd
          ];
          hooks.modules = [ "spectre" ];
        }
        {
          package = aerial-nvim;
          postConfig = read "./fnl/aerial.fnl";
          hooks.modules = [ "aerial" ];
        }
        {
          package = goto-preview;
          postConfig = read "./fnl/goto-preview.fnl";
          hooks.modules = [ "goto-preview" ];
        }
        {
          packages = [
            nvim-jdtls
            spring-boot-nvim
          ];
          postConfig = read "./fnl/jdtls.fnl";
          depends = [
            lsp
            dap
            dap-ui
          ];
          hooks.modules = [ "jdtls" ];
        }
        {
          package = open-nvim;
          depends = [ plenary ];
          postConfig = ''
            require("open").setup({
              system_open = {
                cmd = "${if pkgs.stdenv.isDarwin then "open" else "xdg-open"}",
                args = {},
              }
            })
          '';
          hooks.modules = [ "open" ];
        }
        {
          package = treesj;
          postConfig = read "./fnl/treesj.fnl";
          hooks.modules = [ "treesj" ];
        }
        {
          package = codewindow-nvim;
          postConfig = read "./fnl/codewindow.fnl";
          depends = [ bufferPlugins ];
          hooks.modules = [ "codewindow" ];
        }
        {
          package = img-clip-nvim;
          postConfig = read "./fnl/img-clip.fnl";
          hooks.modules = [
            "img-clip"
            "img-clip.nvim"
            "img-clip.util"
          ];
        }
        {
          package = nvim-window;
          postConfig = read "./fnl/nvim-window.fnl";
          hooks.modules = [ "nvim-window" ];
        }
        {
          package = foldnav-nvim;
          hooks.modules = [ "foldnav" ];
        }
      ];
    };

    commandPlugins = {
      depends = [
        {
          package = claudecode-nvim;
          depends = [ snacks ];
          postConfig = read "./fnl/claudecode.fnl";
          hooks.commands = [ "ClaudeCode" ];
        }
        {
          packages = [ ];
          extraPackages = with pkgs; [ gitu ];
          postConfig = read "./fnl/gitu.fnl";
          hooks.commands = [ "Gitu" ];
        }
        {
          package = vim-startuptime;
          hooks.commands = [ "StartupTime" ];
        }
        {
          package = translate-nvim;
          postConfig = read "./fnl/translate.fnl";
          hooks.commands = [ "Translate" ];
        }
        {
          package = menu;
          depends = [ volt ];
          postConfig = read "./fnl/menu.fnl";
          hooks.commands = [ "OpenMenu" ];
        }
        {
          package = minty;
          depends = [ volt ];
          hooks.commands = [
            "Shades"
            "Huefy"
          ];
        }
        {
          package = timerly;
          depends = [ volt ];
          postConfig = read "./fnl/timerly.fnl";
          hooks.commands = [ "TimerlyToggle" ];
        }
        {
          package = showkeys;
          depends = [ volt ];
          hooks.commands = [ "ShowkeysToggle" ];
        }
        {
          package = NeoZoom-lua;
          postConfig = read "./fnl/neozoom.fnl";
          hooks.commands = [ "NeoZoomToggle" ];
        }
        {
          package = glance-nvim;
          depends = [ trouble ];
          postConfig = read "./fnl/glance.fnl";
          hooks.commands = [ "Glance" ];
        }
        {
          packages = [
            (neorg.overrideAttrs {
              dependencies = [ ];
              doCheck = false;
            })
            neorg-interim-ls
            neorg-conceal-wrap
            (neorg-telescope.overrideAttrs {
              dependencies = [ ];
              doCheck = false;
            })
          ];
          depends = [
            lua-utils-nvim
            nio
            nui
            pathlib-nvim
            plenary
            telescope
            lsp
            dressing
          ];
          postConfig = read "./fnl/neorg.fnl";
          hooks.commands = [
            "Neorg"
            "NeorgFindFile"
            "NeorgFuzzySearch"
            "NeorgScratch"
            "NeorgGit"
            "NeorgGitBranch"
          ];
        }
        {
          package = diffview-nvim;
          depends = [ devicons ];
          postConfig = read "./fnl/diffview.fnl";
          hooks.commands = [
            "DiffviewOpen"
            "DiffviewToggleFiles"
          ];
        }
        {
          package = trace-pr-nvim;
          extraPackages = with pkgs; [ gh ];
          postConfig = read "./fnl/trace-pr.fnl";
          hooks.commands = [ "TracePR" ];
        }
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
        {
          package = undotree;
          preConfig = {
            language = "vim";
            code = ''
              let g:undotree_ShortIndicators=1
              function g:Undotree_CustomMap()
                nmap <buffer> U <plug>UndotreePreviousSavedState
                nmap <buffer> R <plug>UndotreeNextSavedState
                nmap <buffer> u <plug>UndotreeUndo
                nmap <buffer> r <plug>UndotreeRedo
                nmap <buffer> <C-c> <plug>UndotreeClose
              endfunc
            '';
          };
          hooks.commands = [ "UndotreeToggle" ];
        }
        {
          package = winshift-nvim;
          postConfig = read "./fnl/winshift.fnl";
          hooks.commands = [ "WinShift" ];
        }
      ];
    };

    cmdlinePlugins = {
      depends = [
        {
          package = helpview-nvim;
          postConfig = read "./fnl/helpview.fnl";
          depends = [
            devicons
          ];
        }
        {
          package = history-ignore-nvim;
          postConfig = read "./fnl/history-ignore.fnl";
        }
        { package = mkdir-nvim; }
        { package = vimdoc-ja; }
      ];
      postConfig =
        ''
          vim.cmd([[source ${./vim/cmdline-plugins.vim}]])
        ''
        + read "./fnl/cmdline-plugins.fnl";
      hooks.events = [ "CmdlineEnter" ];
    };

    vimLeavePrePlugins = {
      depends = [
        {
          package = logrotate-nvim;
          postConfig = read "./fnl/logrotate.fnl";
        }
      ];
      hooks.events = [ "VimLeavePre" ];
    };

    windowPlugins = {
      depends = [
        {
          package = colorful-winsep-nvim;
          postConfig = read "./fnl/winsep.fnl";
        }
        {
          package = smart-splits-nvim;
          postConfig = read "./fnl/smart-splits.fnl";
        }
        {
          package = winresizer;
          preConfig = {
            language = "vim";
            code = ''
              let g:winresizer_start_key = '<C-w>e'
            '';
          };
        }
      ];
      postConfig = read "./fnl/window-plugins.fnl";
      hooks.events = [ "WinNew" ];
    };

    filetypePlugins = {
      depends = [
        {
          package = nvim-ts-autotag;
          postConfig = read "./fnl/ts-autotag.fnl";
          hooks.fileTypes = [
            "javascript"
            "typescript"
            "jsx"
            "tsx"
            "vue"
            "html"
          ];
        }
        {
          package = markdown-preview-nvim;
          hooks.fileTypes = [ "markdown" ];
        }
        {
          package = crates-nvim;
          postConfig = read "./fnl/crates.fnl";
          depends = [ none-ls ];
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
          package = nginx-vim.overrideAttrs (_: {
            src = pkgs.nix-filter {
              root = nginx-vim.src;
              exclude = [ "ftdetect/nginx.vim" ];
            };
          });
          hooks.fileTypes = [ "nginx" ];
        }
      ];
    };

    dirChangedPrePlugins = {
      depends = [
        {
          package = direnv-vim;
          postConfig = read "./fnl/direnv.fnl";
        }
      ];
      hooks.events = [ "DirChangedPre" ];
    };

    termOpenPlugins = {
      postConfig = read "./fnl/term-open-plugins.fnl";
      hooks.events = [ "TermOpen" ];
    };
  };
}
