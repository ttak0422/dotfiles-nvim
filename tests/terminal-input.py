#!/usr/bin/env python3
"""Exercise the SKK input helper with real pinned NeoZoom, without user daemons."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
cases = [
    'background', 'same-buffer-other-owner', 'zoom-owner', 'owner-close',
    'owner-q', 'helper-toggle-close', 'split-input-moved-to-zoom',
    'orphan-recovery', 'terminal-wiped', 'focus-visibility',
    'reuse-other-terminal', 'repeat-zoom', 'send-failure', 'external-helper-close',
]
for case in cases:
    with tempfile.TemporaryDirectory(prefix='terminal-input-') as temp:
        env = os.environ | {
            'HOME': temp,
            'XDG_CONFIG_HOME': temp + '/config', 'XDG_DATA_HOME': temp + '/data',
            'XDG_STATE_HOME': temp + '/state', 'XDG_CACHE_HOME': temp + '/cache',
            'NVIM_LOG_FILE': temp + '/nvim.log',
            'TERMINAL_INPUT_ROOT': str(root), 'TERMINAL_INPUT_SCENARIO': case,
        }
        result = subprocess.run([
            os.environ['TERMINAL_INPUT_NVIM'], '-n', '--headless', '-u', 'NONE',
            '-i', 'NONE', '-l', str(root / 'tests/terminal-input.lua'),
        ], env=env, capture_output=True, text=True, timeout=10)
        if result.returncode:
            raise AssertionError(f'{case}:\n{result.stdout}{result.stderr}')
        print('PASS ' + case)
