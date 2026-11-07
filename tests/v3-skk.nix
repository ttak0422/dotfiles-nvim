{
  pkgs,
  bundle,
  neovim,
}:
assert builtins.length (builtins.attrNames bundle.graph.nodes) == 2;
assert bundle.graph.extraPackages == [ ];
let
  python = pkgs.python3.withPackages (ps: [ ps.pynvim ]);
in
pkgs.runCommand "v3-skk-tests" { } ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/config" XDG_DATA_HOME="$TMPDIR/data"
  export XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache"
  export SKK_TEST_CAT=${pkgs.coreutils}/bin/cat
  mkdir -p "$HOME"
  ${python}/bin/python ${./v3-skk.py} ${neovim}/bin/nvim
  touch "$out"
''
