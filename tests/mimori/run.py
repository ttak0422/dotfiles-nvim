#!/usr/bin/env python3
"""Run Lua suites with no installed Neovim configuration or provider data."""
import os, subprocess, tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
nvim=os.environ['MIMORI_TEST_NVIM']
assert os.environ.get('MIMORI_KOMADO'), 'set MIMORI_KOMADO to Komado commit 8123dd6 checkout'
for suite in ('client','adapter'):
    with tempfile.TemporaryDirectory(prefix='mimori-lua-',dir='/tmp') as path:
        temp=Path(path)
        for name in ('home','state/nvim','data','cache'): (temp/name).mkdir(parents=True,exist_ok=True)
        env=os.environ|{'HOME':str(temp/'home'),'XDG_STATE_HOME':str(temp/'state'),
          'XDG_DATA_HOME':str(temp/'data'),'XDG_CACHE_HOME':str(temp/'cache'),
          'MIMORI_TEST_ROOT':str(root),'MIMORI_TEST_TMP':str(temp)}
        subprocess.run([nvim,'--clean','--headless','-u','NONE','-i','NONE','-l',str(root/f'tests/mimori/{suite}.lua')],env=env,check=True)
