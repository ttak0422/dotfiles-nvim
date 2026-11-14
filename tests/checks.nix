{ pkgs }:
{
  workflows = pkgs.runCommand "workflow-lint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
    actionlint ${../.github/workflows/flake-check.yml}
    touch "$out"
  '';
}
