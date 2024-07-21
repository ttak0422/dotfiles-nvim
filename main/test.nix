{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
  debug = callPackage ./debug.nix { };
  language = callPackage ./language.nix { };
  treesitter = callPackage ./treesitter.nix { };
in
with pkgs.vimPlugins;
rec {
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
      lib.plenary
      lib.nio
      treesitter.treesitter
      language.lsp
      debug.dap
      vim-test
    ];
    postConfig = {
      code = read ../lua/autogen/neotest.lua;
      args.junit_jar_path = pkgs.javaPackages.junit-console;
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
}
