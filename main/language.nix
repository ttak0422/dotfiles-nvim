{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  style = callPackage ./style.nix { };
  input = callPackage ./input.nix { };
  search = callPackage ./search.nix { };
  treesitter = callPackage ./treesitter.nix { };
  tool = callPackage ./tool.nix { };
  debug = callPackage ./debug.nix { };
  denops = callPackage ./denops.nix { };
in
with pkgs.vimPlugins;
rec {
  lsp = {
    packages = [
      nvim-lspconfig
      # ctags-lsp-nvim
    ];
    depends = [
      {
        package = nvim-dd;
        postConfig = read ../lua/autogen/dd.lua;
      }
      {
        package = garbage-day-nvim;
        preConfig = read ../lua/autogen/garbage-day-pre.lua;
      }
      {
        package = lsp-lens-nvim;
        postConfig = read ../lua/autogen/lsp-lens.lua;
      }
      {
        package = lsp-inlayhints-nvim;
        postConfig = read ../lua/autogen/inlayhints.lua;
      }
      # {
      #   package = diagflow-nvim;
      #   postConfig = read ../lua/autogen/diagflow.lua;
      # }
      {
        package = tiny-inline-diagnostic-nvim;
        postConfig = read ../lua/autogen/tiny-inline-diagnostic.lua;
      }
      style.dressing
      # input.cmp
      search.telescope
      {
        # efm
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
          # ctags-lsp
          pkgs.pkgs-stable.vtsls
        ];
      }
      climbdir-nvim
      # denops.ddc
      {
        package = live-rename-nvim;
        postConfig = read ../lua/autogen/live-rename.lua;
      }
      virtual-types-nvim
    ];
    extraPackages = with pkgs; [
      go
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
      vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.yaml-language-server
      rubyPackages.solargraph
      rust-analyzer
      taplo-cli
      kotlin-language-server
    ];
    preConfig =
      # ''
      #   vim.env.PATH = "${pkgs.universal-ctags}/bin:" .. vim.env.PATH
      # '' +
      read ../lua/autogen/lsp-pre.lua;
    postConfig = read ../lua/autogen/lsp.lua;
    hooks.events = [ "BufReadPost" ];
  };
  gopher = {
    package = gopher-nvim;
    depends = [
      lib.plenary
      treesitter.treesitter
      lsp
      {
        package = goplements-nvim;
        postConfig = read ../lua/autogen/goplements.lua;
      }
      # {
      #   package = goimpl-nvim;
      #   postConfig = read ../lua/autogen/goimpl.lua;
      #   depends = [
      #     search.telescope
      #     popup-nvim
      #   ];
      # }
      {
        package = go-impl-nvim;
        postConfig = read ../lua/autogen/go-impl.lua;
        depends = [
          lib.nui
          lib.plenary
          search.fzf-lua
        ];
      }
    ];
    postConfig = read ../lua/autogen/gopher.lua;
    extraPackages = with pkgs; [
      delve
      gomodifytags
      gotests
      gotools
      iferr
      impl
    ];
    hooks.fileTypes = [
      "go"
      "gomod"
    ];
  };
  haskell-tools = {
    package = haskell-tools-nvim;
    depends = [
      lib.plenary
      lsp
    ];
    preConfig.code = read ../lua/autogen/haskell-tools-pre.lua;
    postConfig = read ../lua/autogen/haskell-tools.lua;
    extraPackages = with pkgs; [
      ghc
      haskellPackages.fourmolu
      haskellPackages.haskell-language-server
    ];
    hooks.fileTypes = [
      "cabal"
      "cabalproject"
      "haskell"
      "lhaskell"
    ];
  };
  jdtls = {
    package = nvim-jdtls;
    # postConfig = configured in after/ftplugin/java
    depends = [
      lsp
      debug.dap
      debug.dap-ui
      {
        package = spring-boot-nvim;
        postConfig = {
          code = read ../lua/autogen/spring-boot.lua;
          args = {
            java_path = "${pkgs.jdk17}/bin/java";
            vscode_spring_boot_path = "${pkgs.vscode-marketplace.vmware.vscode-spring-boot}/share/vscode/extensions/vmware.vscode-spring-boot";
          };
        };
      }
    ];
    hooks.fileTypes = [ "java" ];
  };
  nfnl = {
    package = pkgs.vimPlugins.nfnl;
    extraPackages = with pkgs; [
      sd
      fd
    ];
    hooks.fileTypes = [ "fennel" ];
  };
  null-ls = {
    package = none-ls-nvim;
    depends = [ lib.plenary ];
    extraPackages = with pkgs; [
      # diagnostics
      go-tools # go
      # formatters
      go-tools # go
      gofumpt # go
      fnlfmt # fennel
      nixfmt-rfc-style # nix
      stylua # lua
      shfmt # sh
      google-java-format # java
      yapf # python
      html-tidy # html
      nodePackages.prettier # js, ts (node)
      norg-fmt # neorg
    ];
    postConfig = read ../lua/autogen/null-ls.lua;
    hooks.events = [ "BufReadPost" ];
  };
  rustaceanvim = {
    package = pkgs.vimPlugins.rustaceanvim;
    depends = [
      lsp
      tool.toggleterm
      debug.dap
    ];
    extraPackages = with pkgs; [ graphviz ];
    postConfig = read ../lua/autogen/rustaceanvim.lua;
    hooks.modules = [ "rustaceanvim" ];
  };
  crates = {
    package = crates-nvim;
    postConfig = read ../lua/autogen/crates.lua;
    depends = [ null-ls ];
    hooks.fileTypes = [ "toml" ];
  };
  vim-nix = {
    package = pkgs.vimPlugins.vim-nix;
    hooks = {
      fileTypes = [ "nix" ];
    };
  };
  vtsls = {
    package = nvim-vtsls;
    depends = [ lsp ];
    postConfig = read ../lua/autogen/vtsls.lua;
    hooks.fileTypes = [
      "typescript"
      "javascript"
    ];
  };
  conform = {
    package = conform-nvim;
    postConfig = read ../lua/autogen/conform.lua;
    extraPackages = with pkgs; [ ];
  };
  log-highlight = {
    package = log-highlight-nvim;
    hooks.fileTypes = [ "log" ];
  };
  helpview = {
    package = helpview-nvim.overrideAttrs (old: {
      src = pkgs.nix-filter {
        root = helpview-nvim.src;
        exclude = [ "ftplugin/help.lua" ];
      };
    });
    depends = [ treesitter.treesitter ];
    # configured in after/ftplugin
    hooks = {
      modules = [ "helpview" ];
      fileTypes = [ "help" ];
    };
  };
}
