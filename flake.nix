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

    # nodePackages
    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      flake = false;
    };

    # plugins
    v2-fff-nvim = {
      url = "github:dmtrKovalenko/fff.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-bufdel = {
      url = "github:ojroques/nvim-bufdel";
      flake = false;
    };
    Comment-nvim = {
      url = "github:numToStr/Comment.nvim";
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
    haskell-tools-nvim = {
      url = "github:MrcJkb/haskell-tools.nvim";
      flake = false;
    };
    heirline-nvim = {
      url = "github:rebelot/heirline.nvim";
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
    qf-nvim = {
      url = "github:ten3roberts/qf.nvim";
      flake = false;
    };
    vim-qfreplace = {
      url = "github:thinca/vim-qfreplace";
      flake = false;
    };
    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };
    smart-splits-nvim = {
      url = "github:mrjones2014/smart-splits.nvim";
      flake = false;
    };
    vim-startuptime = {
      url = "github:dstein64/vim-startuptime";
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
    trouble-nvim = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    trim-nvim = {
      url = "github:cappyzawa/trim.nvim";
      flake = false;
    };
    tshjkl-nvim = {
      url = "github:gsuuon/tshjkl.nvim";
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
    nvim-window-picker = {
      url = "github:s1n7ax/nvim-window-picker";
      flake = false;
    };
    winshift-nvim = {
      url = "github:sindrets/winshift.nvim";
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
    bufferline-nvim = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    neco-vim = {
      url = "github:Shougo/neco-vim";
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
    CopilotChat-nvim = {
      url = "github:CopilotC-Nvim/CopilotChat.nvim";
      flake = false;
    };
    winresizer = {
      url = "github:simeji/winresizer";
      flake = false;
    };
    bigfile-nvim = {
      url = "github:LunarVim/bigfile.nvim";
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
    crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    sorairo = {
      url = "github:ttak0422/sorairo/v2";
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
    goplements-nvim = {
      url = "github:maxandron/goplements.nvim";
      flake = false;
    };
    goimpl-nvim = {
      url = "github:edolphin-ydf/goimpl.nvim";
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
    nvim-yati = {
      url = "github:yioneko/nvim-yati";
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
    guess-indent-nvim = {
      url = "github:NMAC427/guess-indent.nvim";
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
    treesj = {
      url = "github:Wansmer/treesj";
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
          lib,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = import ./overlays.nix inputs;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "terraform"
              ];
          };
          bundler-nvim = {
            v2 = import ./v2 {
              inherit inputs' pkgs lib;
            };
          }
          // (import ./tests {
            inherit inputs';
            inherit pkgs;
          });
        }
        // import ./apps.nix { inherit pkgs; };
    };
}
