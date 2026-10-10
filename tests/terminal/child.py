#!/usr/bin/env python3
"""Local PTY fixture: record argv/cwd, then wait for an explicit exit request."""
import json
import os
import sys
from pathlib import Path

report = Path(os.environ['TERMINAL_TEST_TMP']) / f'child-{os.getpid()}.json'
report.write_text(json.dumps({'argv': sys.argv[1:], 'cwd': os.getcwd(), 'pid': os.getpid()}))
print('fixture ready', flush=True)
for line in sys.stdin:
    if line.startswith('exit '):
        sys.exit(int(line.split()[1]))
