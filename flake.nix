{
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "ttak0422-dotfiles-nvim.cachix.org-1:LHmQa5l92iTmX+6sKRZOPz2MsunlWcvQfmgFuCjyTmE="
    ];
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    bundler = {
      url = "github:ttak0422/bundler/v3";
      # url = "path:/Users/ttak0422/ghq/github.com/ttak0422/bundler";
      # url = "path:/home/ttak0422/ghq/github.com/ttak0422/bundler";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    loaded-nvim = {
      url = "github:ttak0422/loaded-nvim";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # javaPackages
    junit-console = {
      url = "https://repo.maven.apache.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.2/junit-platform-console-standalone-1.10.2.jar";
      flake = false;
    };
    jol = {
      url = "https://repo.maven.apache.org/maven2/org/openjdk/jol/jol-cli/0.16/jol-cli-0.16-full.jar";
      flake = false;
    };

    # plugins
    denops-shared-server-service = {
      url = "github:ttak0422/denops-shared-server-service";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    morimo = {
      # url = "path:/Users/ttak0422/ghq/github.com/ttak0422/morimo";
      url = "github:ttak0422/morimo";
      flake = false;
    };
    nvim-config-local = {
      url = "github:klen/nvim-config-local";
      flake = false;
    };
    nvim-dap-repl-highlights = {
      url = "github:LiadOz/nvim-dap-repl-highlights";
      flake = false;
    };
    tree-sitter-fsharp = {
      url = "github:ionide/tree-sitter-fsharp";
      flake = false;
    };
    tree-sitter-norg-meta = {
      url = "github:nvim-neorg/tree-sitter-norg-meta";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    telescope-sg = {
      url = "github:Marskey/telescope-sg";
      flake = false;
    };
    telescope-repo-nvim = {
      url = "github:cljoly/telescope-repo.nvim";
      flake = false;
    };
    telescope-smart-history-nvim = {
      url = "github:nvim-telescope/telescope-smart-history.nvim";
      flake = false;
    };
    telescope-dap-nvim = {
      url = "github:nvim-telescope/telescope-dap.nvim";
      flake = false;
    };
    telescope-undo-nvim = {
      url = "github:debugloop/telescope-undo.nvim";
      flake = false;
    };
    telescope-frecency-nvim = {
      url = "github:nvim-telescope/telescope-frecency.nvim";
      flake = false;
    };
    telescope-file-browser-nvim = {
      url = "github:nvim-telescope/telescope-file-browser.nvim";
      flake = false;
    };
    telescope-ui-select-nvim = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    telescope-live-grep-args-nvim = {
      url = "github:nvim-telescope/telescope-live-grep-args.nvim";
      flake = false;
    };
    telescope-command-palette-nvim = {
      url = "github:LinArcX/telescope-command-palette.nvim";
      flake = false;
    };
    telescope-sonictemplate-nvim = {
      url = "github:tamago324/telescope-sonictemplate.nvim";
      flake = false;
    };
    telescope-live-grep-args = {
      url = "github:nvim-telescope/telescope-live-grep-args.nvim";
      flake = false;
    };
    telescope-fzf-native-nvim = {
      url = "github:nvim-telescope/telescope-fzf-native.nvim";
      flake = false;
    };
    vim-sonictemplate = {
      url = "github:ttak0422/vim-sonictemplate/feature/support-java-test-directory";
      flake = false;
    };
    lir-nvim = {
      url = "github:tamago324/lir.nvim";
      flake = false;
    };
    lir-git-status-nvim = {
      url = "github:tamago324/lir-git-status.nvim";
      flake = false;
    };
    oil-nvim = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    oil-vcs-status = {
      url = "github:SirZenith/oil-vcs-status";
      flake = false;
    };
    codewindow-nvim = {
      url = "github:gorbit99/codewindow.nvim";
      flake = false;
    };
    harpoon = {
      url = "github:ThePrimeagen/harpoon";
      flake = false;
    };
    harpoon-2 = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    neorg = {
      url = "github:nvim-neorg/neorg";
      flake = false;
    };
    neorg-jupyter = {
      url = "github:tamton-aquib/neorg-jupyter";
      flake = false;
    };
    neorg-templates = {
      url = "github:pysan3/neorg-templates";
      flake = false;
    };
    neorg-telescope = {
      url = "github:nvim-neorg/neorg-telescope";
      flake = false;
    };
    lua-utils-nvim = {
      url = "github:nvim-neorg/lua-utils.nvim";
      flake = false;
    };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    pathlib-nvim = {
      url = "github:pysan3/pathlib.nvim";
      flake = false;
    };
    legendary-nvim = {
      url = "github:mrjones2014/legendary.nvim";
      flake = false;
    };
    neogit = {
      url = "github:TimUntersberger/neogit";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-calc = {
      url = "github:hrsh7th/cmp-calc";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-nvim-lua = {
      url = "github:hrsh7th/cmp-nvim-lua";
      flake = false;
    };
    cmp_luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    cmp-nvim-lsp-signature-help = {
      url = "github:hrsh7th/cmp-nvim-lsp-signature-help";
      flake = false;
    };
    cmp-cmdline-history = {
      url = "github:dmitmel/cmp-cmdline-history";
      flake = false;
    };
    cmp-nvim-lsp-document-symbol = {
      url = "github:hrsh7th/cmp-nvim-lsp-document-symbol";
      flake = false;
    };
    cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };
    garbage-day-nvim = {
      url = "github:Zeioth/garbage-day.nvim";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    lsp-lens-nvim = {
      url = "github:VidocqH/lsp-lens.nvim";
      flake = false;
    };
    lsp-inlayhints-nvim = {
      url = "github:lvimuser/lsp-inlayhints.nvim";
      flake = false;
    };
    diagflow-nvim = {
      url = "github:dgagn/diagflow.nvim";
      flake = false;
    };
    dressing-nvim = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };
    climbdir-nvim = {
      url = "github:kyoh86/climbdir.nvim";
      flake = false;
    };
    efmls-configs-nvim = {
      url = "github:creativenull/efmls-configs-nvim";
      flake = false;
    };
    LuaSnip = {
      url = "https://github.com/L3MON4D3/LuaSnip";
      flake = false;
      type = "git";
      submodules = true;
    };
    glance-nvim = {
      url = "github:DNLHC/glance.nvim";
      flake = false;
    };
    neogen = {
      url = "github:danymat/neogen";
      flake = false;
    };
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };
    vim-vsnip-integ = {
      url = "github:hrsh7th/vim-vsnip-integ";
      flake = false;
    };
    nvim-dd = {
      url = "github:yorickpeterse/nvim-dd";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    vim-ambiwidth = {
      url = "github:rbtnn/vim-ambiwidth";
      flake = false;
    };
    vim-asterisk = {
      url = "github:haya14busa/vim-asterisk";
      flake = false;
    };
    auto-indent-nvim = {
      url = "github:VidocqH/auto-indent.nvim";
      flake = false;
    };
    better-escape-nvim = {
      url = "github:max397574/better-escape.nvim";
      flake = false;
    };
    nvim-bqf = {
      url = "github:/kevinhwang91/nvim-bqf";
      flake = false;
    };
    nvim-pqf = {
      url = "github:yorickpeterse/nvim-pqf";
      flake = false;
    };
    nvim-bufdel = {
      url = "github:ojroques/nvim-bufdel";
      flake = false;
    };
    nvim-colorizer-lua = {
      url = "github:norcalli/nvim-colorizer.lua";
      flake = false;
    };
    Comment-nvim = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    nvim_context_vt = {
      url = "github:haringsrob/nvim_context_vt";
      flake = false;
    };
    denops-vim = {
      url = "github:vim-denops/denops.vim";
      flake = false;
    };
    detour-nvim = {
      url = "github:carbon-steel/detour.nvim";
      flake = false;
    };
    diffview-nvim = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    direnv-vim = {
      url = "github:direnv/direnv.vim";
      flake = false;
    };
    nvim-FeMaco-lua = {
      url = "github:AckslD/nvim-FeMaco.lua";
      flake = false;
    };
    leap-ast-nvim = {
      url = "github:ggandor/leap-ast.nvim";
      flake = false;
    };
    leap-spooky-nvim = {
      url = "github:ggandor/leap-spooky.nvim";
      flake = false;
    };
    leap-nvim = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };
    vim-repeat = {
      url = "github:/tpope/vim-repeat";
      flake = false;
    };
    flit-nvim = {
      url = "github:ggandor/flit.nvim";
      flake = false;
    };
    flow-nvim = {
      url = "github:arjunmahishi/flow.nvim";
      flake = false;
    };
    nvim-fundo = {
      url = "github:kevinhwang91/nvim-fundo";
      flake = false;
    };
    promise-async = {
      url = "github:kevinhwang91/promise-async";
      flake = false;
    };
    gina-vim = {
      url = "github:lambdalisue/gina.vim";
      flake = false;
    };
    gin-vim = {
      url = "github:lambdalisue/gin.vim";
      flake = false;
    };
    git-conflict-nvim = {
      url = "github:akinsho/git-conflict.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    gopher-nvim = {
      url = "github:olexsmir/gopher.nvim";
      flake = false;
    };
    goto-preview = {
      url = "github:rmagatti/goto-preview";
      flake = false;
    };
    harpoonline = {
      url = "github:abeldekat/harpoonline";
      flake = false;
    };
    haskell-tools-nvim = {
      url = "github:MrcJkb/haskell-tools.nvim";
      flake = false;
    };
    heirline-nvim = {
      url = "github:rebelot/heirline.nvim";
      flake = false;
    };
    heirline-components-nvim = {
      url = "github:Zeioth/heirline-components.nvim";
      flake = false;
    };
    lsp-progress-nvim = {
      url = "github:linrongbin16/lsp-progress.nvim";
      flake = false;
    };
    scope-nvim = {
      url = "github:tiagovla/scope.nvim";
      flake = false;
    };
    history-ignore-nvim = {
      url = "github:yutkat/history-ignore.nvim";
      flake = false;
    };
    hlchunk-nvim = {
      url = "github:shellRaining/hlchunk.nvim";
      flake = false;
    };
    nvim-hlslens = {
      url = "github:kevinhwang91/nvim-hlslens";
      flake = false;
    };
    hydra-nvim = {
      url = "github:nvimtools/hydra.nvim";
      flake = false;
    };
    img-clip-nvim = {
      url = "github:HakonHarnes/img-clip.nvim";
      flake = false;
    };
    indent-o-matic = {
      url = "github:Darazaki/indent-o-matic";
      flake = false;
    };
    JABS-nvim = {
      url = "github:matbme/JABS.nvim";
      flake = false;
    };
    nvim-jdtls = {
      url = "github:mfussenegger/nvim-jdtls";
      flake = false;
    };
    nvim-lastplace = {
      url = "github:mrcjkb/nvim-lastplace";
      flake = false;
    };
    sqlite-lua = {
      url = "github:kkharji/sqlite.lua";
      flake = false;
    };
    marks-nvim = {
      url = "github:chentoast/marks.nvim";
      flake = false;
    };
    mkdir-nvim = {
      url = "github:jghauser/mkdir.nvim";
      flake = false;
    };
    mkdnflow-nvim = {
      url = "github:/jakewvincent/mkdnflow.nvim";
      flake = false;
    };
    nap-nvim = {
      url = "github:liangxianzhe/nap.nvim";
      flake = false;
    };
    BufferBrowser = {
      url = "sourcehut:~marcc/BufferBrowser";
      flake = false;
    };
    NeoZoom-lua = {
      url = "github:nyngwang/NeoZoom.lua";
      flake = false;
    };
    nfnl = {
      url = "github:Olical/nfnl";
      flake = false;
    };
    noice-nvim = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };
    none-ls-nvim = {
      url = "github:nvimtools/none-ls.nvim";
      flake = false;
    };
    none-ls-extras-nvim = {
      url = "github:nvimtools/none-ls-extras.nvim";
      flake = false;
    };
    none-ls-shellcheck-nvim = {
      url = "github:gbprod/none-ls-shellcheck.nvim";
      flake = false;
    };
    none-ls-luacheck-nvim = {
      url = "github:gbprod/none-ls-luacheck.nvim";
      flake = false;
    };
    numb-nvim = {
      url = "github:nacro90/numb.nvim";
      flake = false;
    };
    nvim-window = {
      url = "github:yorickpeterse/nvim-window";
      flake = false;
    };
    octo-nvim = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    open-nvim = {
      url = "github:ofirgall/open.nvim";
      flake = false;
    };
    overseer-nvim = {
      url = "github:stevearc/overseer.nvim";
      flake = false;
    };
    toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    term-gf-nvim = {
      url = "github:yutkat/term-gf.nvim";
      flake = false;
    };
    project-nvim = {
      url = "github:ahmedkhalf/project.nvim";
      flake = false;
    };
    qf-nvim = {
      url = "github:ten3roberts/qf.nvim";
      flake = false;
    };
    vim-qfreplace = {
      url = "github:thinca/vim-qfreplace";
      flake = false;
    };
    reacher-nvim = {
      url = "github:notomo/reacher.nvim";
      flake = false;
    };
    registers-nvim = {
      url = "github:tversteeg/registers.nvim";
      flake = false;
    };
    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };
    skkeleton = {
      url = "github:vim-skk/skkeleton";
      flake = false;
    };
    smart-splits-nvim = {
      url = "github:mrjones2014/smart-splits.nvim";
      flake = false;
    };
    nvim-spectre = {
      url = "github:nvim-pack/nvim-spectre";
      flake = false;
    };
    vim-startuptime = {
      url = "github:dstein64/vim-startuptime";
      flake = false;
    };
    statuscol-nvim = {
      url = "github:luukvbaal/statuscol.nvim";
      flake = false;
    };
    stickybuf-nvim = {
      url = "github:stevearc/stickybuf.nvim";
      flake = false;
    };
    tabout-nvim = {
      url = "github:abecodes/tabout.nvim";
      flake = false;
    };
    tint-nvim = {
      url = "github:levouh/tint.nvim";
      flake = false;
    };
    todo-comments-nvim = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    trouble-nvim = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    toolwindow-nvim = {
      url = "github:EthanJWright/toolwindow.nvim";
      flake = false;
    };
    denops-translate-vim = {
      url = "github:skanehira/denops-translate.vim";
      flake = false;
    };
    trim-nvim = {
      url = "github:cappyzawa/trim.nvim";
      flake = false;
    };
    nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };
    tshjkl-nvim = {
      url = "github:gsuuon/tshjkl.nvim";
      flake = false;
    };
    nvim-ufo = {
      url = "github:kevinhwang91/nvim-ufo";
      flake = false;
    };
    indent-blankline-nvim = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    undotree = {
      url = "github:mbbill/undotree";
      flake = false;
    };
    venn-nvim = {
      url = "github:jbyuki/venn.nvim";
      flake = false;
    };
    vim-markdown = {
      url = "github:preservim/vim-markdown";
      flake = false;
    };
    vim-nix = {
      url = "github:LnL7/vim-nix";
      flake = false;
    };
    vimdoc-ja = {
      url = "github:vim-jp/vimdoc-ja";
      flake = false;
    };
    nvim-vtsls = {
      url = "github:yioneko/nvim-vtsls";
      flake = false;
    };
    waitevent-nvim = {
      url = "github:notomo/waitevent.nvim";
      flake = false;
    };
    which-key-nvim = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    nvim-window-picker = {
      url = "github:s1n7ax/nvim-window-picker";
      flake = false;
    };
    colorful-winsep-nvim = {
      url = "github:nvim-zh/colorful-winsep.nvim";
      flake = false;
    };
    winshift-nvim = {
      url = "github:sindrets/winshift.nvim";
      flake = false;
    };
    ddu-vim = {
      url = "github:Shougo/ddu.vim";
      flake = false;
    };
    ddu-ui-ff = {
      url = "github:Shougo/ddu-ui-ff";
      flake = false;
    };
    ddu-ui-filter = {
      url = "github:Shougo/ddu-ui-filer";
      flake = false;
    };
    ddu-source-rg = {
      url = "github:shun/ddu-source-rg";
      flake = false;
    };
    ddu-commands-vim = {
      url = "github:Shougo/ddu-commands.vim";
      flake = false;
    };
    ddu-kind-file = {
      url = "github:Shougo/ddu-kind-file";
      flake = false;
    };
    ddu-source-file_rec = {
      url = "github:Shougo/ddu-source-file_rec";
      flake = false;
    };
    ddu-source-buffer = {
      url = "github:shun/ddu-source-buffer";
      flake = false;
    };
    ddu-vim-ui-select = {
      url = "github:matsui54/ddu-vim-ui-select";
      flake = false;
    };
    ddu-source-file = {
      url = "github:Shougo/ddu-source-file";
      flake = false;
    };
    ddu-column-filename = {
      url = "github:Shougo/ddu-column-filename";
      flake = false;
    };
    ddu-filter-kensaku = {
      url = "github:Milly/ddu-filter-kensaku";
      flake = false;
    };
    ddu-filter-matcher_substring = {
      url = "github:Shougo/ddu-filter-matcher_substring";
      flake = false;
    };
    ddu-filter-fzf = {
      url = "github:yuki-yano/ddu-filter-fzf";
      flake = false;
    };
    ddu-filter-merge = {
      url = "github:Milly/ddu-filter-merge";
      flake = false;
    };
    ddu-filter-converter_display_word = {
      url = "github:Shougo/ddu-filter-converter_display_word";
      flake = false;
    };
    ddu-source-file_external = {
      url = "github:matsui54/ddu-source-file_external";
      flake = false;
    };
    ddu-source-file_fd = {
      url = "github:nabezokodaikon/ddu-source-file_fd";
      flake = false;
    };
    ddu-source-git_stash = {
      url = "github:peacock0803sz/ddu-source-git_stash";
      flake = false;
    };
    ddu-source-git_diff = {
      url = "github:kuuote/ddu-source-git_diff";
      flake = false;
    };
    ddu-source-mr = {
      url = "github:kuuote/ddu-source-mr";
      flake = false;
    };
    ddu-filter-converter_hl_dir = {
      url = "github:kyoh86/ddu-filter-converter_hl_dir";
      flake = false;
    };
    ddu-filter-sorter_reversed = {
      url = "github:Shougo/ddu-filter-sorter_reversed";
      flake = false;
    };
    ddu-filter-sorter_alpha = {
      url = "github:Shougo/ddu-filter-sorter_alpha";
      flake = false;
    };
    ddu-source-command_history = {
      url = "github:matsui54/ddu-source-command_history";
      flake = false;
    };
    ddu-filter-converter_devicon = {
      url = "github:uga-rosa/ddu-filter-converter_devicon";
      flake = false;
    };
    ddu-source-git_log = {
      url = "github:kyoh86/ddu-source-git_log";
      flake = false;
    };
    ddu-source-vim = {
      url = "github:Shougo/ddu-source-vim";
      flake = false;
    };
    ddu-source-action = {
      url = "github:Shougo/ddu-source-action";
      flake = false;
    };
    ddu-source-git_status = {
      url = "github:kuuote/ddu-source-git_status";
      flake = false;
    };
    ddu-source-ghq = {
      url = "github:4513ECHO/ddu-source-ghq";
      flake = false;
    };
    ddu-filter-zf = {
      url = "github:hasundue/ddu-filter-zf";
      flake = false;
    };
    ddu-source-custom-list = {
      url = "github:liquidz/ddu-source-custom-list";
      flake = false;
    };
    ddu-source-register = {
      url = "github:Shougo/ddu-source-register";
      flake = false;
    };
    ddu-source-file_old = {
      url = "github:Shougo/ddu-source-file_old";
      flake = false;
    };
    ddu-column-icon_filename = {
      url = "github:ryota2357/ddu-column-icon_filename";
      flake = false;
    };
    ddu-source-line = {
      url = "github:Shougo/ddu-source-line";
      flake = false;
    };
    ddu-source-lsp = {
      url = "github:uga-rosa/ddu-source-lsp";
      flake = false;
    };
    ddu-filter-matcher_hidden = {
      url = "github:Shougo/ddu-filter-matcher_hidden";
      flake = false;
    };
    ddu-filter-matcher_files = {
      url = "github:Shougo/ddu-filter-matcher_files";
      flake = false;
    };
    mr-vim = {
      url = "github:lambdalisue/mr.vim";
      flake = false;
    };
    neotest-golang = {
      url = "github:fredrikaverpil/neotest-golang";
      flake = false;
    };
    neotest-vim-test = {
      url = "github:nvim-neotest/neotest-vim-test";
      flake = false;
    };
    neotest-deno = {
      url = "github:MarkEmmons/neotest-deno";
      flake = false;
    };
    neotest-haskell = {
      url = "github:mrcjkb/neotest-haskell";
      flake = false;
    };
    neotest-scala = {
      url = "github:stevanmilic/neotest-scala";
      flake = false;
    };
    neotest-dotnet = {
      url = "github:Issafalcon/neotest-dotnet";
      flake = false;
    };
    neotest-elixir = {
      url = "github:jfpedroza/neotest-elixir";
      flake = false;
    };
    neotest-rust = {
      url = "github:rouge8/neotest-rust";
      flake = false;
    };
    neotest-pest = {
      url = "github:theutz/neotest-pest";
      flake = false;
    };
    neotest-phpunit = {
      url = "github:olimorris/neotest-phpunit";
      flake = false;
    };
    neotest-testthat = {
      url = "github:shunsambongi/neotest-testthat";
      flake = false;
    };
    neotest-dart = {
      url = "github:sidlatau/neotest-dart";
      flake = false;
    };
    neotest-minitest = {
      url = "github:zidhuss/neotest-minitest";
      flake = false;
    };
    neotest-rspec = {
      url = "github:olimorris/neotest-rspec";
      flake = false;
    };
    neotest-playwright = {
      url = "github:thenbe/neotest-playwright";
      flake = false;
    };
    neotest-vitest = {
      url = "github:marilari88/neotest-vitest";
      flake = false;
    };
    neotest-jest = {
      url = "github:nvim-neotest/neotest-jest";
      flake = false;
    };
    neotest-java = {
      url = "github:rcasia/neotest-java";
      flake = false;
    };
    neotest-go = {
      url = "github:nvim-neotest/neotest-go";
      flake = false;
    };
    neotest-plenary = {
      url = "github:nvim-neotest/neotest-plenary";
      flake = false;
    };
    neotest-python = {
      url = "github:nvim-neotest/neotest-python";
      flake = false;
    };
    neotest = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
    vim-test = {
      url = "github:vim-test/vim-test/";
      flake = false;
    };
    nvim-lint = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    copilot-lua = {
      url = "github:zbirenbaum/copilot.lua";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    surround-ui-nvim = {
      url = "github:roobert/surround-ui.nvim";
      flake = false;
    };
    fzf-lua = {
      url = "github:/ibhagwan/fzf-lua";
      flake = false;
    };
    dropbar-nvim = {
      url = "github:Bekaboo/dropbar.nvim";
      flake = false;
    };
    alpha-nvim = {
      url = "github:goolord/alpha-nvim";
      flake = false;
    };
    btw-nvim = {
      url = "github:letieu/btw.nvim";
      flake = false;
    };
    ddu-filter-matcher_ignore_files = {
      url = "github:Shougo/ddu-filter-matcher_ignore_files";
      flake = false;
    };
    ddu-filter-matcher_ignores = {
      url = "github:Shougo/ddu-filter-matcher_ignores";
      flake = false;
    };
    ddu-filter-matcher_relative = {
      url = "github:Shougo/ddu-filter-matcher_relative";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ ./neovim.nix ];
      perSystem =
        { pkgs, ... }:
        {
          apps =
            let
              inherit (pkgs.lib.strings) concatStringsSep;
              join = concatStringsSep " ";
              update-inputs =
                { name, plugins }:
                pkgs.writeShellApplication {
                  inherit name;
                  text = ''
                    nix flake lock ${join (map (p: "--update-input ${p}") plugins)}
                  '';
                };
            in
            {
              show-inputs = {
                type = "app";
                program = pkgs.writeShellApplication {
                  name = "show-inputs";
                  runtimeInputs = with pkgs; [
                    jq
                    coreutils
                  ];
                  text = "nix flake metadata --json | jq -r '.locks.nodes | keys[]'";
                };
              };
              update-ddu-plugins = {
                type = "app";
                program =
                  update-inputs {
                    name = "update-ddu-plugins";
                    plugins = [
                      "ddu-column-filename"
                      "ddu-column-icon_filename"
                      "ddu-commands-vim"
                      "ddu-filter-converter_devicon"
                      "ddu-filter-converter_display_word"
                      "ddu-filter-converter_hl_dir"
                      "ddu-filter-fzf"
                      "ddu-filter-kensaku"
                      "ddu-filter-matcher_files"
                      "ddu-filter-matcher_hidden"
                      "ddu-filter-matcher_ignore_files"
                      "ddu-filter-matcher_ignores"
                      "ddu-filter-matcher_relative"
                      "ddu-filter-matcher_substring"
                      "ddu-filter-merge"
                      "ddu-filter-sorter_alpha"
                      "ddu-filter-sorter_reversed"
                      "ddu-filter-zf"
                      "ddu-kind-file"
                      "ddu-source-action"
                      "ddu-source-buffer"
                      "ddu-source-command_history"
                      "ddu-source-custom-list"
                      "ddu-source-file"
                      "ddu-source-file_external"
                      "ddu-source-file_fd"
                      "ddu-source-file_old"
                      "ddu-source-file_rec"
                      "ddu-source-ghq"
                      "ddu-source-git_diff"
                      "ddu-source-git_log"
                      "ddu-source-git_stash"
                      "ddu-source-git_status"
                      "ddu-source-line"
                      "ddu-source-lsp"
                      "ddu-source-mr"
                      "ddu-source-register"
                      "ddu-source-rg"
                      "ddu-source-vim"
                      "ddu-ui-ff"
                      "ddu-ui-filter"
                      "ddu-vim"
                      "ddu-vim-ui-select"
                    ];
                  }
                  + "/bin/update-ddu-plugins";
              };
            };
        };
    };
}
