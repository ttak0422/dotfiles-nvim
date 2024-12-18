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
      neotest-dart
      neotest-deno
      neotest-dotnet
      neotest-elixir
      neotest-golang
      neotest-haskell
      neotest-java
      neotest-jest
      neotest-minitest
      neotest-pest
      neotest-phpunit
      neotest-playwright
      neotest-plenary
      neotest-python
      neotest-rspec
      neotest-rust
      neotest-scala
      neotest-testthat
      neotest-vim-test
      neotest-vitest
      pkgs.vimPlugins.neotest
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
      code = read ../lua/neotest.lua;
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
