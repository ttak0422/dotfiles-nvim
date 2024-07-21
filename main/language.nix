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
in
with pkgs.vimPlugins;
rec {
  lsp = {
    packages = [ nvim-lspconfig ];
    depends = [
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
      {
        package = diagflow-nvim;
        postConfig = read ../lua/autogen/diagflow.lua;
      }
      style.dressing
      input.cmp
      search.telescope
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
    preConfig = read ../lua/lsp-pre.lua;
    postConfig = {
      code = read ../lua/autogen/lsp.lua;
      args = {
        capabilities_path = ../lua/lsp-capabilities.lua;
        on_attach_path = ../lua/autogen/lsp-on-attach.lua;
      };
    };
    hooks.events = [ "BufReadPost" ];
  };
  gopher = {
    package = gopher-nvim;
    depends = [
      lib.plenary
      treesitter.treesitter
      lsp
    ];
    postConfig = read ../lua/autogen/gopher.lua;
    extraPackages = with pkgs; [
      gomodifytags
      impl
      gotests
      iferr
      delve
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
    postConfig = {
      code = read ../lua/autogen/haskell-tools.lua;
      args = {
        on_attach_path = ../lua/autogen/lsp-on-attach.lua;
        capabilities_path = ../lua/lsp-capabilities.lua;
      };
    };
    extraPackages = with pkgs; [
      ghc
      haskellPackages.fourmolu
      haskellPackages.haskell-language-server
    ];
    hooks.fileTypes = [
      "cagbal"
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
      dap
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
      gofumpt
      go-tools
    ];
    postConfig = read ../lua/autogen/null-ls.lua;
    hooks.userEvents = [ "SpecificFileEnter" ];
  };
  rustaceanvim = {
    package = pkgs.vimPlugins.rustaceanvim;
    depends = [
      lsp
      tool.toggleterm
      debug.dap
    ];
    extraPackages = with pkgs; [ graphviz ];
    preConfig = {
      code = read ../lua/autogen/rustaceanvim-pre.lua;
      args.on_attach_path = ../lua/autogen/lsp-on-attach.lua;
    };
    hooks.modules = [ "rustaceanvim" ];
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
}
