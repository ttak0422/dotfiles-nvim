{ pkgs }:
{
  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
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
