#!/usr/bin/env python3
"""Run only local fixture processes, with an isolated pterm socket directory."""
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parents[2]
with tempfile.TemporaryDirectory(prefix='terminal-', dir='/tmp') as directory:
    temp = Path(directory)
    child = temp / 'fixture child'
    shutil.copy(root / 'tests/terminal/child.py', child)
    child.chmod(0o755)
    (temp / 'fixture-command').symlink_to(child)
    pterm = temp / 'pterm bridge'
    pterm.symlink_to(os.environ['TERMINAL_TEST_PTERM'])
    cwd = temp / 'working directory'
    cwd.mkdir()
    env = os.environ | {
        'TERMINAL_TEST_ROOT': str(root), 'TERMINAL_TEST_TMP': str(temp),
        'TERMINAL_TEST_PTERM': str(pterm), 'TERMINAL_TEST_CHILD': str(child),
        'TERMINAL_TEST_CWD': str(cwd), 'PTERM_SOCKET_DIR': str(temp / 'sockets'),
        'SHELL': str(child), 'PATH': str(temp) + os.pathsep + os.environ['PATH'],
        'XDG_CONFIG_HOME': str(temp / 'config'), 'XDG_DATA_HOME': str(temp / 'data'),
        'XDG_STATE_HOME': str(temp / 'state'), 'XDG_CACHE_HOME': str(temp / 'cache'),
        'NVIM_LOG_FILE': str(temp / 'nvim.log'),
    }
    try:
        subprocess.run([os.environ['TERMINAL_TEST_NVIM'], '--headless', '-u', 'NONE',
                        '-i', 'NONE', '-l', str(root / 'tests/terminal/command.lua')],
                       env=env, check=True, timeout=60)
    finally:
        # Removing only this test's sockets asks its daemons to stop, even on failure.
        shutil.rmtree(temp / 'sockets', ignore_errors=True)
