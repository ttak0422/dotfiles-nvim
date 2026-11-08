# Focused assertions share the real profile, but isolate all writable state.
{ name, script }:
{
  pkgs,
  bundle,
  neovim,
}:
let
  python = pkgs.python3.withPackages (ps: [ ps.pynvim ]);
  lua = pkgs.writeText "${name}.lua" script;
  runner = pkgs.writeText "${name}.py" ''
    import os
    import pathlib
    import signal
    import sys

    import pynvim

    def timeout(_signum, _frame):
        raise TimeoutError("${name}: Neovim feature check timed out")

    signal.signal(signal.SIGALRM, timeout)
    signal.alarm(90)
    nvim = pynvim.attach("child", argv=[sys.argv[1], "--embed", "--headless", "-n", "-i", "NONE"])
    try:
        assert nvim.exec_lua('return package.loaded.divine ~= nil')
        assert nvim.exec_lua('return vim.tbl_contains(vim.v.argv, vim.env.PLUGIN_TEST_BUNDLE .. "/init.lua")')
        assert nvim.eval("v:errmsg") == "", (nvim.eval("v:errmsg"), nvim.command_output("messages"))
        nvim.exec_lua(pathlib.Path(sys.argv[2]).read_text())
        print("${name}: configured behavior passed")
    finally:
        signal.alarm(10)
        try:
            nvim.command("qa!")
        except EOFError:
            pass
        finally:
            nvim.close()
  '';
in
pkgs.runCommand "nvim-feature-${name}" { } ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/config"
  export XDG_DATA_HOME="$TMPDIR/data"
  export XDG_STATE_HOME="$TMPDIR/state"
  export XDG_CACHE_HOME="$TMPDIR/cache"
  export PLUGIN_TEST_BUNDLE=${bundle}
  mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
  ${python}/bin/python ${runner} ${neovim}/bin/nvim ${lua}
  touch "$out"
''
