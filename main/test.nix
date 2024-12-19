{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  read = builtins.readFile;
  debug = callPackage ./debug.nix { };
  language = callPackage ./language.nix { };
  lib = callPackage ./lib.nix { };
  quickfix = callPackage ./quickfix.nix { };
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
      debug.dap
      language.lsp
      lib.nio
      lib.plenary
      quickfix.bqf
      treesitter.treesitter
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
        "NeotestTogglePanel"
        "NeotestOpenOutput"
      ];
      modules = [ "neotest" ];
    };
  };
}
