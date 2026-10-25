#!/usr/bin/env python3
"""Integration checks with real Deno workers; needs network on the first run.

Set DENOPS_TEST_NVIM to unwrapped Neovim, DENOPS_TEST_PAYLOAD to the built v2
payload.json, and DENO_DIR to a disposable cache. Optional DENOPS_TEST_DENO
overrides the payload's runtime for compatibility checks. HOME/XDG/git fixtures
are isolated. This runs headless and with a PTY; it never activates dotfiles.
"""
import errno
import fcntl
import os
import pty
import select
import struct
import subprocess
import tempfile
import termios
import time
from pathlib import Path

script = Path(__file__).with_suffix('.lua')
for terminal in (False, True):
    with tempfile.TemporaryDirectory(prefix='denops-', dir='/tmp') as directory:
        root = Path(directory)
        repo = root / 'repo'
        repo.mkdir()
        (repo / 'tracked.txt').write_text('fixture\n')
        (root / 'dict').write_text(';; okuri-ari entries.\n;; okuri-nasi entries.\nにほん /日本/\nかな /仮名/カナ/\n')
        env = os.environ | {'HOME': directory, 'DENOPS_TEST_TMP': directory,
            'TERM': 'xterm-256color', 'GIT_CONFIG_NOSYSTEM': '1', 'NVIM_LOG_FILE': str(root / 'nvim.log'),
            'XDG_CONFIG_HOME': str(root / 'config'), 'XDG_DATA_HOME': str(root / 'data'),
            'XDG_STATE_HOME': str(root / 'state'), 'XDG_CACHE_HOME': str(root / 'cache')}
        for args in (['init', '-b', 'fixture'], ['add', 'tracked.txt'],
                     ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
                      '-c', 'commit.gpgsign=false', 'commit', '-m', 'fixture']):
            subprocess.run(['git', '-C', str(repo), *args], env=env, check=True, capture_output=True)
        (repo / 'untracked.txt').write_text('untracked fixture\n')
        cmd = [os.environ['DENOPS_TEST_NVIM'], '-n', '-u', 'NONE', '-i', 'NONE',
               '-c', 'lua dofile(' + repr(str(script)) + ')']
        if not terminal:
            subprocess.run([cmd[0], '--headless', *cmd[1:]], env=env, cwd=repo,
                           check=True, timeout=180)
        else:
            master, slave = pty.openpty()
            fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 120, 0, 0))
            proc = subprocess.Popen(cmd, stdin=slave, stdout=slave, stderr=slave, env=env, cwd=repo)
            os.close(slave)
            output = bytearray()
            try:
                deadline = time.monotonic() + 180
                while proc.poll() is None:
                    if time.monotonic() > deadline:
                        raise TimeoutError('terminal Neovim exceeded 180 seconds')
                    if select.select([master], [], [], 0.1)[0]:
                        try:
                            output.extend(os.read(master, 65536))
                        except OSError as error:
                            if error.errno != errno.EIO:
                                raise
                assert proc.returncode == 0, output.decode(errors='replace')
            finally:
                if proc.poll() is None:
                    proc.kill()
                    proc.wait()
                os.close(master)
        print('Denops ' + ('terminal' if terminal else 'headless') + ': passed', flush=True)
