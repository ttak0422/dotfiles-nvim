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
    nixpkgs-nightly.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs-neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    bundler = {
      url = "github:ttak0422/bundler/v3";
      # url = "path:/Users/tak/ghq/github.com/ttak0422/bundler";
      # url = "path:/home/ttak0422/ghq/github.com/ttak0422/bundler";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # javaPackages
    junit-console = {
      url = "https://repo.maven.apache.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.2/junit-platform-console-standalone-1.10.2.jar";
      flake = false;
    };
    jol = {
      url = "https://repo.maven.apache.org/maven2/org/openjdk/jol/jol-cli/0.17/jol-cli-0.17-full.jar";
      flake = false;
    };

    # language server
    ctags-lsp = {
      url = "github:netmute/ctags-lsp";
      flake = false;
    };

    # nodePackages
    vtsls = {
      url = "git+https://github.com/yioneko/vtsls?submodules=1";
      flake = false;
    };

    # plugins
    morimo = {
      url = "github:ttak0422/morimo/v2";
      # url = "path:/home/ttak0422/ghq/github.com/ttak0422/morimo";
      # url = "path:/Users/tak/ghq/github.com/ttak0422/morimo";
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
      url = "github:mattn/vim-sonictemplate";
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
    lsp-lens-nvim = {
      url = "github:VidocqH/lsp-lens.nvim";
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
    vim-lastplace = {
      url = "github:farmergreg/vim-lastplace";
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
    vim-bufsurf = {
      url = "github:ton/vim-bufsurf";
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
    skkeleton_indicator-nvim = {
      url = "github:delphinus/skkeleton_indicator.nvim/v2";
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
    mr-vim = {
      url = "github:lambdalisue/mr.vim";
      flake = false;
    };
    vim-mr = {
      url = "github:lambdalisue/vim-mr";
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
    pum-vim = {
      url = "github:Shougo/pum.vim";
      flake = false;
    };
    denops-popup-preview-vim = {
      url = "github:matsui54/denops-popup-preview.vim";
      flake = false;
    };
    denops-signature_help = {
      url = "github:matsui54/denops-signature_help";
      flake = false;
    };
    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    spring-boot-nvim = {
      url = "github:JavaHello/spring-boot.nvim";
      flake = false;
    };
    springboot-nvim = {
      url = "github:elmcgill/springboot-nvim";
      flake = false;
    };
    log-highlight-nvim = {
      url = "github:fei6409/log-highlight.nvim";
      flake = false;
    };
    bufferline-nvim = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    neco-vim = {
      url = "github:Shougo/neco-vim";
      flake = false;
    };
    fix-auto-scroll-nvim = {
      url = "github:BranimirE/fix-auto-scroll.nvim";
      flake = false;
    };
    markview-nvim = {
      url = "github:OXY2DEV/markview.nvim";
      flake = false;
    };
    foldnav-nvim = {
      url = "github:domharries/foldnav.nvim";
      flake = false;
    };
    helpview-nvim = {
      url = "github:OXY2DEV/helpview.nvim";
      flake = false;
    };
    dotfyle-metadata-nvim = {
      url = "github:creativenull/dotfyle-metadata.nvim";
      flake = false;
    };
    CopilotChat-nvim = {
      url = "github:CopilotC-Nvim/CopilotChat.nvim";
      flake = false;
    };
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
      flake = false;
    };
    winresizer = {
      url = "github:simeji/winresizer";
      flake = false;
    };
    virtual-types-nvim = {
      url = "github:jubnzv/virtual-types.nvim";
      flake = false;
    };
    endscroll-nvim = {
      url = "github:plax-00/endscroll.nvim";
      flake = false;
    };
    bigfile-nvim = {
      url = "github:LunarVim/bigfile.nvim";
      flake = false;
    };
    no-neck-pain-nvim = {
      url = "github:shortcuts/no-neck-pain.nvim";
      flake = false;
    };
    highlight-undo-nvim = {
      url = "github:tzachar/highlight-undo.nvim";
      flake = false;
    };
    auto-save-nvim = {
      url = "github:pocco81/auto-save.nvim";
      flake = false;
    };
    screenkey-nvim = {
      url = "github:NStefan002/screenkey.nvim";
      flake = false;
    };
    tiny-inline-diagnostic-nvim = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    vim-translator = {
      url = "github:voldikss/vim-translator";
      flake = false;
    };
    translate-nvim = {
      url = "github:uga-rosa/translate.nvim";
      flake = false;
    };
    crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    ed-cmd-nvim = {
      url = "github:smilhey/ed-cmd.nvim";
      flake = false;
    };
    pgmnt-vim = {
      url = "github:cocopon/pgmnt.vim";
      flake = false;
    };
    smear-cursor-nvim = {
      url = "github:sphamba/smear-cursor.nvim";
      flake = false;
    };
    sorairo = {
      url = "github:ttak0422/sorairo";
      flake = false;
    };
    skk-dict = {
      url = "github:skk-dev/dict";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    other-nvim = {
      url = "github:rgroli/other.nvim";
      flake = false;
    };
    dmacro-vim = {
      url = "github:tani/dmacro.vim";
      flake = false;
    };
    nvim-dap-go = {
      url = "github:leoluz/nvim-dap-go";
      flake = false;
    };
    vimade = {
      url = "github:TaDaa/vimade";
      flake = false;
    };
    denippet-vim = {
      url = "github:uga-rosa/denippet.vim";
      flake = false;
    };
    switch-vim = {
      url = "github:AndrewRadev/switch.vim";
      flake = false;
    };
    hardtime-nvim = {
      url = "github:m4xshen/hardtime.nvim";
      flake = false;
    };
    goplements-nvim = {
      url = "github:maxandron/goplements.nvim";
      flake = false;
    };
    goimpl-nvim = {
      url = "github:edolphin-ydf/goimpl.nvim";
      flake = false;
    };
    popup-nvim = {
      url = "github:nvim-lua/popup.nvim";
      flake = false;
    };
    aerial-nvim = {
      url = "github:stevearc/aerial.nvim";
      flake = false;
    };
    nvim-regexplainer = {
      url = "github:bennypowers/nvim-regexplainer";
      flake = false;
    };
    volt = {
      url = "github:nvzone/volt";
      flake = false;
    };
    minty = {
      url = "github:nvzone/minty";
      flake = false;
    };
    timerly = {
      url = "github:nvzone/timerly";
      flake = false;
    };
    showkeys = {
      url = "github:nvzone/showkeys";
      flake = false;
    };
    menu = {
      url = "github:nvzone/menu";
      flake = false;
    };
    nvim-yati = {
      url = "github:yioneko/nvim-yati";
      flake = false;
    };
    ctags-lsp-nvim = {
      url = "github:netmute/ctags-lsp.nvim";
      flake = false;
    };
    logrotate-nvim = {
      url = "github:ttak0422/logrotate-nvim";
      flake = false;
    };
    go-impl-nvim = {
      url = "github:fang2hou/go-impl.nvim";
      flake = false;
    };
    nginx-vim = {
      url = "github:chr4/nginx.vim";
      flake = false;
    };
    inc-rename-nvim = {
      url = "github:smjonas/inc-rename.nvim";
      flake = false;
    };
    guess-indent-nvim = {
      url = "github:NMAC427/guess-indent.nvim";
      flake = false;
    };
    command-and-cursor-nvim = {
      url = "github:moyiz/command-and-cursor.nvim";
      flake = false;
    };
    autoclose-nvim = {
      url = "github:m4xshen/autoclose.nvim";
      flake = false;
    };
    kmonad-vim = {
      url = "github:kmonad/kmonad-vim";
      flake = false;
    };
    toggler = {
      url = "github:ttak0422/toggler-nvim";
      flake = false;
    };
    capture-vim = {
      url = "github:tyru/capture.vim";
      flake = false;
    };
    trace-pr-nvim = {
      url = "github:h3pei/trace-pr.nvim";
      flake = false;
    };
    lasterisk-nvim = {
      url = "github:rapan931/lasterisk.nvim";
      flake = false;
    };
    v2-blink-cmp.url = "github:Saghen/blink.cmp";
    treesj = {
      url = "github:Wansmer/treesj";
      flake = false;
    };
    blink-cmp-avante = {
      url = "github:Kaiser-Yang/blink-cmp-avante";
      flake = false;
    };
    blink-compat = {
      url = "github:Saghen/blink.compat";
      flake = false;
    };
    nvim-ts-context-commentstring = {
      url = "github:JoosepAlviste/nvim-ts-context-commentstring";
      flake = false;
    };
    neorg-interim-ls = {
      url = "github:benlubas/neorg-interim-ls";
      flake = false;
    };
    neorg-conceal-wrap = {
      url = "github:/benlubas/neorg-conceal-wrap";
      flake = false;
    };
    claudecode-nvim = {
      url = "github:coder/claudecode.nvim";
      flake = false;
    };
    norg.url = "github:nvim-neorg/tree-sitter-norg/dev";
    norg-meta.url = "github:nvim-neorg/tree-sitter-norg-meta";
    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      flake = false;
    };
    claude-code-nvim = {
      url = "github:greggh/claude-code.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.bundler.flakeModules.neovim ];
      perSystem =
        {
          inputs',
          system,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = import ./overlays.nix inputs;
          };
          bundler-nvim = {
            v2 = import ./v2 {
              inherit inputs';
              inherit pkgs;
            };
          };
        }
        // import ./apps.nix { inherit pkgs; };
    };
}
