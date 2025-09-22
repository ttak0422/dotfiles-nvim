{
  inputs',
  pkgs,
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
    if vim.g.neovide then dofile("${./lua/autogen/neovide.lua}") end
    ${read "./fnl/init.fnl"}
  '';

  after = {
    ftdetect = {
      nginx = {
        language = "vim";
        code = ''
          source ${pkgs.vimPlugins.v2.nginx-vim}/ftdetect/nginx.vim
          au BufRead,BufNewFile *.nginxconf set ft=nginx
        '';
      };
    };
    ftplugin = {
      Avante = read "./fnl/after/ftplugin/Avante.fnl";
      AvanteInput = read "./fnl/after/ftplugin/AvanteInput.fnl";
      fennel = read "./fnl/after/ftplugin/fennel.fnl";
      gitcommit = read "./fnl/after/ftplugin/gitcommit.fnl";
      java = {
        # WIP
        code = read "./fnl/after/ftplugin/java_mini.fnl";
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
            attach_path = ./lua/autogen/lsp-attach.lua;
          };
      };
      jproperties = read "./fnl/after/ftplugin/jproperties.fnl";
      make = read "./fnl/after/ftplugin/make.fnl";
      markdown = read "./fnl/after/ftplugin/markdown.fnl";
      nix = read "./fnl/after/ftplugin/nix.fnl";
      norg = read "./fnl/after/ftplugin/norg.fnl";
      qf = read "./fnl/after/ftplugin/qf.fnl";
      qfreplace = read "./fnl/after/ftplugin/qfreplace.fnl";
      json = read "./fnl/after/ftplugin/json.fnl";
      yaml = read "./fnl/after/ftplugin/yaml.fnl";
      toml = read "./fnl/after/ftplugin/toml.fnl";
    };
    lsp = {
      denols = read "./fnl/after/lsp/denols.fnl";
      efm = read "./fnl/after/lsp/efm.fnl";
      fennel_ls = read "./fnl/after/lsp/fennel_ls.fnl";
      jdtls = read "./fnl/after/lsp/jdtls.fnl";
      lua_ls = read "./fnl/after/lsp/lua_ls.fnl";
      nil_ls = read "./fnl/after/lsp/nil_ls.fnl";
      typos_lsp = read "./fnl/after/lsp/typos_lsp.fnl";
      vtsls = read "./fnl/after/lsp/vtsls.fnl";
      yamlls = read "./fnl/after/lsp/yamlls.fnl";
    };
  };
  eager = with pkgs.vimPlugins.v2; {
    morimo.package = morimo;
    plenary.package = plenary-nvim;
    nui.package = nui-nvim;
    config-local.package = nvim-config-local;
    snacks = {
      package = snacks-nvim;
      startupConfig = read "./fnl/snacks.fnl";
    };
    notify = {
      package = nvim-notify;
      startupConfig = read "./fnl/notify.fnl";
    };
    noice = {
      package = noice-nvim;
      startupConfig = read "./fnl/noice.fnl";
    };
    treesitter = {
      packages = [
        pkgs.vimPlugins.nvim-treesitter
        pkgs.vimPlugins.nvim-treesitter-textobjects
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
              echo "${pkgs.lib.strings.concatStringsSep "," pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies}" \
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
    scope = {
      package = scope-nvim;
      startupConfig = read "./fnl/scope.fnl";
    };
    # bufferline = {
    #   package = bufferline-nvim;
    #   startupConfig = read "./fnl/bufferline.fnl";
    # };
    lastplace = {
      package = vim-lastplace;
      startupConfig = {
        language = "vim";
        code = ''
          let g:lastplace_ignore = "gitcommit,gitrebase,undotree,gitsigns-blame"
          let g:lastplace_ignore_buftype = "help,nofile,quickfix"
        '';
      };
    };
    lsp = {
      package = nvim-lspconfig;
      startupConfig = {
        code = read "./fnl/lsp.fnl";
        args.attach_path = ./lua/autogen/lsp-attach.lua;
      };
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
        # kotlin-language-server
        v2.kotlin-lsp
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
        vtsls
      ];
    };
    none-ls = {
      packages = with pkgs.vimPlugins.v2; [
        none-ls-nvim
        none-ls-extras-nvim
        none-ls-shellcheck-nvim
        none-ls-luacheck-nvim
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
      startupConfig = {
        code = read "./fnl/none-ls.fnl";
        args = {
          # TODO: support Linux
          idea = "${pkgs.jetbrains.idea-community}/Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea";
        };
      };
    };
    gitsigns = {
      package = gitsigns-nvim;
      startupConfig = read "./fnl/gitsigns.fnl";
    };
    heirline = {
      package = heirline-nvim;
      startupConfig = read "./lua/heirline.lua";
    };
    # 動作しない？
    # bufresize = {
    #   package = bufresize-nvim;
    #   startupConfig = read "./fnl/bufresize.fnl";
    # };
    # direnv = {
    #   package = direnv-vim;
    #   startupConfig = read "./fnl/direnv.fnl";
    # };
    # alpha = {
    #   package = alpha-nvim;
    #   startupConfig = read "./fnl/alpha.fnl";
    # };
  };

  lazy = with pkgs.vimPlugins.v2; rec {
    # colorschemes
    sorairo.package = pkgs.vimPlugins.v2.sorairo;

    # utils
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
      depends = [ devicons ];
      postConfig = read "./fnl/render-markdown.fnl";
      hooks.fileTypes = [
        "markdown"
        "Avante"
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
        render-markdown
        copilot
        dressing
        mcphub
      ];
      # TODO: fix priority
      extraPackages = with pkgs; [ curl ];
      postConfig = read "./fnl/avante.fnl";
      hooks = {
        commands = [ "AvanteFocus" ];
        events = [ "BufReadPost" ];
      };
    };

    mcphub = {
      package = mcphub-nvim;
      depends = [
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
        package.cpath = package.cpath .. ';${inputs'.v2-blink-cmp.packages.blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.dylib'
        ${read "./fnl/blink.fnl"}
      '';
      hooks.modules = [ "blink.cmp" ];
    };

    luasnip = {
      package = LuaSnip;
      postConfig = read "./fnl/luasnip.fnl";
    };

    # TODO: refactor
    lspPlugins = {
      packages = [ ];
      depends = [
        {
          package = lensline-nvim;
          postConfig = read "./fnl/lensline.fnl";
        }
        {
          package = lsp-progress-nvim;
          postConfig = read "./fnl/lsp-progress.fnl";
        }
        {
          package = garbage-day-nvim;
          postConfig = read "./fnl/garbage-day.fnl";
        }
        {
          package = tiny-inline-diagnostic-nvim;
          postConfig = read "./fnl/tiny-inline-diagnostic.fnl";
        }
        {
          package = neogen;
          depends = [ luasnip ];
          postConfig = read "./fnl/neogen.fnl";
        }
      ];
      hooks.events = [ "LspAttach" ];
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
        {
          package = goplements-nvim;
          postConfig = read "./fnl/goplements.fnl";
        }
        {
          package = go-impl-nvim;
          postConfig = read "./fnl/go-impl.fnl";
          depends = [
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

    hlslens = {
      package = nvim-hlslens;
      postConfig = ''
        require("hlslens").setup()
      '';
      hooks.events = [ "CmdlineEnter" ];
    };

    bufferPlugins = {
      depends = [
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
        }
        {
          package = nap-nvim;
          depends = [ vim-bufsurf ];
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
          package = diffview-nvim;
          postConfig = read "./fnl/diffview.fnl";
        }
        {
          package = statuscol-nvim;
          postConfig = read "./fnl/statuscol.fnl";
        }
        {
          package = nvim-ufo;
          depends = [ promise-async ];
          postConfig = read "./fnl/ufo.fnl";
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
          package = hydra-nvim;
          postConfig = read "./fnl/hydra.fnl";
        }
        {
          package = nvim-autopairs;
          postConfig = read "./fnl/autopairs.fnl";
        }
        {
          package = guess-indent-nvim;
          postConfig = read "./fnl/guess-indent.fnl";
        }
        {
          package = nvim-dd;
          postConfig = read "./fnl/dd.fnl";
        }
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
        # {
        #   package = wf-nvim;
        #   postConfig = read "./fnl/wf.fnl";
        # }
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
          depends = [ hlslens ];
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
      package = toggler;
      extraPackages = with pkgs; [ v2-tmux ];
      postConfig = {
        code = read "./fnl/toggle-plugins.fnl";
        args.tmux_path = "${pkgs.v2-tmux}/bin/tmux";
      };
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
        telescope-mr
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        telescope-sonictemplate-nvim
      ];
      depends = [
        quickfixPlugins
        {
          package = vim-mr;
          depends = [ denops ];
          useDenops = true;
        }
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
                src = ./../v2/tmpl/sonic;
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
        "TelescopeBufferName"
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
        telescope
        blink
      ];
      extraPackages = with pkgs; [ pngpaste ];
      postConfig = read "./fnl/obsidian.fnl";
      hooks.commands = [
        "Obsidian"
        "ObsidianScratch"
        "ObsidianGit"
        "ObsidianGitBranch"
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
          package = inlay-hints-nvim;
          postConfig = read "./fnl/inlay-hints.fnl";
          hooks.modules = [ "inlay-hints" ];
        }
        {
          package = lookup-nvim;
          depends = [ telescope ];
          postConfig = read "./fnl/lookup.fnl";
          hooks.modules = [ "lookup" ];
        }
        {
          package = goto-preview;
          postConfig = read "./fnl/goto-preview.fnl";
          hooks.modules = [ "goto-preview" ];
        }
        {
          package = nvim-spectre;
          depends = [
            devicons
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
            dap
            dap-ui
          ];
          hooks.modules = [ "jdtls" ];
        }
        {
          package = open-nvim;
          depends = [ ];
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
          package = videre-nvim;
          postConfig = read "./fnl/videre.fnl";
          depends = [
            graph_view_yaml_parser
            graph_view_toml_parser
          ];
          hooks.commands = [ "Videre" ];
        }
        {
          package = no-neck-pain-nvim;
          postConfig = read "./fnl/no-neck-pain.fnl";
          hooks.commands = [ "NoNeckPain" ];
        }
        {
          package = lush-nvim;
          hooks.commands = [
            "Lushify"
            "LushRunTutorial"
          ];
        }
        {
          package = nvim-colorizer-lua;
          postConfig = read "./fnl/colorizer.fnl";
          hooks.commands = [ "ColorizerToggle" ];
        }
        {
          package = venn-nvim;
          hooks.commands = [
            "VBox"
            "VBoxD"
            "VBoxH"
          ];
        }
        {
          package = img-clip-nvim;
          postConfig = read "./fnl/img-clip.fnl";
          hooks.commands = [ "PasteImage" ];
        }
        {
          package = claudecode-nvim;
          depends = [ ];
          postConfig = read "./fnl/claudecode.fnl";
          hooks.commands = [ "ClaudeCode" ];
        }
        {
          package = claude-code-nvim;
          postConfig = read "./fnl/claude-code.fnl";
          # hooks.commands = [ "ClaudeCode" ];
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
            (pkgs.vimPlugins.neorg.overrideAttrs {
              dependencies = [ ];
              doCheck = false;
            })
            neorg-interim-ls
            neorg-conceal-wrap
            (pkgs.vimPlugins.neorg-telescope.overrideAttrs {
              dependencies = [ ];
              doCheck = false;
            })
          ];
          depends = [
            pkgs.vimPlugins.lua-utils-nvim
            pkgs.vimPlugins.pathlib-nvim
            nio
            telescope
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
          package = harpoon;
          depends = [ ];
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
        {
          package = inc-rename-nvim;
          postConfig = read "./fnl/inc-rename.fnl";
          hooks.commands = [ "IncRename" ];
        }
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
        {
          package = keep-split-ratio-nvim;
          postConfig = read "./fnl/keep-split-ratio.fnl";
        }
      ];
      postConfig = read "./fnl/window-plugins.fnl";
      hooks.events = [ "WinNew" ];
    };

    filetypePlugins = {
      depends = [
        {
          package = csvview-nvim;
          postConfig = read "./fnl/csvview.fnl";
          hooks.fileTypes = [
            "csv"
            "tsv"
          ];
        }
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
          package = pkgs.vimPlugins.markdown-preview-nvim;
          hooks.fileTypes = [ "markdown" ];
        }
        {
          package = crates-nvim;
          postConfig = read "./fnl/crates.fnl";
          depends = [ ];
          hooks.fileTypes = [ "toml" ];
        }
        {
          package = vim-nix;
          hooks = {
            fileTypes = [ "nix" ];
          };
        }
        {
          package = nfnl;
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

    # dirChangedPrePlugins = {
    #   depends = [
    #     {
    #       package = direnv-vim;
    #       postConfig = read "./fnl/direnv.fnl";
    #     }
    #   ];
    #   hooks.events = [ "DirChangedPre" ];
    # };

    termOpenPlugins = {
      postConfig = read "./fnl/term-open-plugins.fnl";
      hooks.events = [ "TermOpen" ];
    };
  };
}
