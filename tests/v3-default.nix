{
  pkgs,
  bundle,
  neovim,
}:
assert bundle.graph.nodes == { };
assert bundle.graph.extraPackages == [ ];
pkgs.runCommand "v3-default-tests" { } ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/config" XDG_DATA_HOME="$TMPDIR/data"
  export XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache"
  export V3_BUNDLE=${bundle}
  mkdir -p "$HOME"
  test -d ${bundle}/pack/divine/opt
  test -z "$(ls -A ${bundle}/pack/divine/opt)"
  test ! -e ${bundle}/pack/divine/start
  ${neovim}/bin/nvim --headless -n -i NONE \
    -c 'lua dofile("${./v3-default.lua}")' -c 'qa!'
  touch "$out"
''
