{ pkgs, ... }:
let
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (pkgs.stdenv) mkDerivation;
  read = builtins.readFile;
in
{
  package = pkgs.pkgs-stable.neovim-unwrapped;
  extraPackages = with pkgs; [ ];
  extraConfig = ''
    vim.cmd([[
      ${read ./vim/prelude.vim}
    ]]);
    (function()
      ${read ./lua/prelude.lua}
    end)()
  '';
  after = { };
  eager = with pkgs.vimPlugins; {
    morimo = {
      package = morimo;
      startupConfig = "vim.cmd([[colorscheme morimo]])";
    };
    config-local = {
      package = nvim-config-local;
      startupConfig = read ./lua/config-local.lua;
    };
  };
  lazy = with pkgs.vimPlugins; rec {
    plenary = {
      package = plenary-nvim;
    };
    treesitter = {
      packages = [ nvim-treesitter ];
      postConfig =
        let
          buildGrammar =
            { language, src }:
            mkDerivation {
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
          fsharp = buildGrammar {
            language = "fsharp";
            src = tree-sitter-fsharp;
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
                    fsharp
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
            ${read ./lua/treesitter.lua}
          '';
          args = {
            parser = toString parserDrv;
          };
        };
      hooks = {
        events = [ "InsertEnter" ];
      };
    };
    telescope = {
      packages = [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        telescope-sonictemplate-nvim
        telescope-sg
      ];
      depends = [
        plenary
        sonictemplate
      ];
      postConfig = read ./lua/telescope.lua;
      extraPackages = with pkgs; [
        # for live-grep-args
        ripgrep
        # for sg
        ast-grep
      ];
      hooks = {
        commands = [ "Telescope" ];
      };
    };
    sonictemplate = {
      package = vim-sonictemplate;
      preConfig =
        let
          template = mkDerivation {
            pname = "sonictemplate";
            version = "custom";
            src = ./tmpl/sonic;
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
    };
  };
}
