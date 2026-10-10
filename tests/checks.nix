{ pkgs }:
{
  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
    touch "$out"
  '';

  terminal =
    pkgs.runCommand "terminal-command-tests"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        TERMINAL_TEST_NVIM = "${pkgs.neovim-unwrapped}/bin/nvim";
        TERMINAL_TEST_PTERM = "${pkgs.vimPlugins.v2.pterm-daemon}/bin/pterm";
        TERMINAL_TEST_PTERM_PLUGIN = pkgs.vimPlugins.v2.pterm;
        TERMINAL_TEST_NFNL = pkgs.vimPlugins.v2.nfnl;
        TERMINAL_TEST_TOGGLETERM = pkgs.vimPlugins.v2.toggleterm-nvim;
        TERMINAL_TEST_TOGGLER = pkgs.vimPlugins.v2.toggler-nvim;
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
