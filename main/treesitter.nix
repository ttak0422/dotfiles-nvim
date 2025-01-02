{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  inherit (pkgs.lib.strings) concatStringsSep;
  read = builtins.readFile;
  lib = callPackage ./lib.nix { };
in
with pkgs.vimPlugins;
rec {
  treesitter = {
    packages = [ nvim-treesitter ];
    postConfig =
      let
        buildGrammar =
          { language, src }:
          pkgs.stdenv.mkDerivation {
            inherit src;
            pname = "custom-grammar-${language}";
            version = "custom";
            CFLAGS = [
              "-Isrc"
              "-O2"
            ];
            CXXFLAGS = [
              "-Isrc"
              "-O2"
            ];
            buildPhase = ''
              if [[ -e src/scanner.cc ]]; then
              $CXX -fPIC -c src/scanner.cc -o scanner.o $CXXFLAGS
              elif [[ -e src/scanner.c ]]; then
              $CC -fPIC -c src/scanner.c -o scanner.o $CFLAGS
              fi
              $CC -fPIC -c src/parser.c -o parser.o $CFLAGS
              rm -rf parser
              $CXX -shared -o parser *.o
            '';
            installPhase = ''
              mkdir -p $out/parser
              mv parser $out/parser/${language}.so
            '';
          };
        dap-repl = buildGrammar {
          language = "dap_repl";
          src = nvim-dap-repl-highlights;
        };
        norg-meta = buildGrammar {
          language = "norg_meta";
          src = tree-sitter-norg-meta;
        };
        parserDrv = pkgs.stdenv.mkDerivation {
          name = "treesitter-custom-grammars";
          buildCommand = ''
            mkdir -p $out/parser
            echo "${
              concatStringsSep "," (
                nvim-treesitter.withAllGrammars.dependencies
                ++ [
                  dap-repl
                  norg-meta
                ]
              )
            }" \
            | tr ',' '\n' \
            | xargs -I {} find {} -not -type d -name '*.so' \
            | xargs -I {} ln -s {} $out/parser
          '';
        };
      in
      {
        code = ''
          require('morimo').load('treesitter')
          ${read ../lua/autogen/treesitter.lua}
        '';
        args = {
          parser = toString parserDrv;
        };
      };
    hooks.events = [ "BufReadPost" ];
  };
  auto-indent = {
    package = auto-indent-nvim;
    depends = [ treesitter ];
    postConfig = read ../lua/autogen/auto-indent.lua;
    hooks.events = [ "InsertEnter" ];
  };
  context-vt = {
    package = nvim_context_vt;
    depends = [ treesitter ];
    postConfig = read ../lua/autogen/context-vt.lua;
    hooks.events = [ "BufReadPost" ];
  };
  hlchunk = {
    package = hlchunk-nvim;
    depends = [ treesitter ];
    postConfig = read ../lua/autogen/hlchunk.lua;
    hooks.events = [ "CursorMoved" ];
  };
  ts-autotag = {
    package = nvim-ts-autotag;
    postConfig = read ../lua/autogen/ts-autotag.lua;
    depends = [ treesitter ];
    hooks.fileTypes = [
      "javascript"
      "typescript"
      "jsx"
      "tsx"
      "vue"
      "html"
    ];
  };
  regexplainer = {
    package = nvim-regexplainer;
    postConfig = read ../lua/autogen/regexplainer.lua;
    depends = [
      treesitter
      lib.nui
    ];
  };
}
