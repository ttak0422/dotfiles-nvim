{ pkgs }:
{
  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
    touch "$out"
  '';

  checkmake =
    pkgs.runCommand "checkmake-config-tests"
      {
        nativeBuildInputs = [
          pkgs.neovim-unwrapped
          pkgs.checkmake
        ];
        CHECKMAKE_TEST_SHELL = pkgs.runtimeShell;
        NONE_LS_PLUGIN_DIR = pkgs.vimPlugins.v2.none-ls-nvim;
        NFNL_PLUGIN_DIR = pkgs.vimPlugins.v2.nfnl;
        PLENARY_PLUGIN_DIR = pkgs.vimPlugins.v2.plenary-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        nvim --headless -u NONE -i NONE -l tests/checkmake.lua
        touch "$out"
      '';

  terminal =
    pkgs.runCommand "terminal-picker-tests"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        TERMINAL_TEST_NVIM = "${pkgs.neovim-unwrapped}/bin/nvim";
        TERMINAL_TEST_PTERM = "${pkgs.vimPlugins.v2.pterm-daemon}/bin/pterm";
        TERMINAL_TEST_PTERM_PLUGIN = pkgs.vimPlugins.v2.pterm;
        TERMINAL_TEST_NFNL = pkgs.vimPlugins.v2.nfnl;
        TERMINAL_TEST_TELESCOPE = pkgs.vimPlugins.v2.telescope-nvim;
        TERMINAL_TEST_PLENARY = pkgs.vimPlugins.v2.plenary-nvim;
        TERMINAL_TEST_LIVE_GREP_ARGS = pkgs.vimPlugins.v2.telescope-live-grep-args-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        patchShebangs tests/terminal/child.py
        python3 tests/terminal/run.py
        touch "$out"
      '';

  mimori =
    pkgs.runCommand "mimori-tests"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.neovim-unwrapped
        ];
        MIMORI_TEST_NVIM = "${pkgs.neovim-unwrapped}/bin/nvim";
        MIMORI_KOMADO = pkgs.vimPlugins.v2.komado-nvim;
      }
      ''
        cp -R ${../.} source
        chmod -R u+w source
        cd source
        patchShebangs tests/mimori/fake-cli.py
        python3 tests/mimori/run.py
        touch "$out"
      '';
}
