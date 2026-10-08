#!/usr/bin/env python3
"""Run Lua suites with no installed Neovim configuration or provider data."""
import argparse, os, subprocess, tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
nvim=os.environ['MIMORI_TEST_NVIM']
assert os.environ.get('MIMORI_KOMADO'), 'set MIMORI_KOMADO to Komado commit 8123dd6 checkout'
parser=argparse.ArgumentParser()
parser.add_argument('--snapshots',type=Path,help='write actual before/after Komado buffers here')
args=parser.parse_args()
if args.snapshots: args.snapshots.mkdir(parents=True,exist_ok=True)
for suite in ('packaging','client','adapter','priority','labels','presentation','hover'):
    with tempfile.TemporaryDirectory(prefix='mimori-lua-',dir='/tmp') as path:
        temp=Path(path)
        for name in ('home','state/nvim','data','cache'): (temp/name).mkdir(parents=True,exist_ok=True)
        env=os.environ|{'HOME':str(temp/'home'),'XDG_STATE_HOME':str(temp/'state'),
          'XDG_DATA_HOME':str(temp/'data'),'XDG_CACHE_HOME':str(temp/'cache'),
          'MIMORI_TEST_ROOT':str(root),'MIMORI_TEST_TMP':str(temp),'NVIM_LOG_FILE':str(temp/'nvim.log')}
        command=[nvim,'--clean','--headless','-u','NONE','-i','NONE','-l',str(root/f'tests/mimori/{suite}.lua')]
        if suite=='presentation': env['MIMORI_SNAPSHOT_OUT']=str(temp/'actual.txt')
        subprocess.run(command,env=env,check=True)
        if suite=='presentation':
            actual=(temp/'actual.txt').read_text()
            expected=root/'tests/mimori/snapshots/after.txt'
            if not args.snapshots and expected.exists():
                assert actual==expected.read_text(),'rendered snapshot changed; review --snapshots output'
            if args.snapshots:
                (args.snapshots/'after.txt').write_text(actual)
                baseline=temp/'baseline.lua'
                baseline.write_bytes(subprocess.check_output(['git','show',
                    '6393d59cc9af839493c23b3de73817e4385ba72e:v2/lua/mimori/komado.lua'],cwd=root))
                env['MIMORI_BASELINE']=str(baseline)
                env['MIMORI_SNAPSHOT_OUT']=str(args.snapshots/'before.txt')
                subprocess.run(command,env=env,check=True)
