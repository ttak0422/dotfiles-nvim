#!/usr/bin/env python3
"""Synthetic, isolated process fixture; never accesses provider files."""
import fcntl, json, os, sys, time
from pathlib import Path
args = sys.argv[1:]
def arg(name, default=None):
    return args[args.index(name) + 1] if name in args else default
root = Path(arg('--state-dir'))
lock = (root / 'running.lock').open('a')
try:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    (root / 'overlap').write_text('overlap')
mode = (root / 'mode').read_text().strip() if (root / 'mode').exists() else 'full'
with (root / 'calls').open('a') as f:
    f.write(json.dumps({'pid': os.getpid(), 'time': time.time(), 'args': args}) + '\n')
if args[0] == 'ensure':
    if mode == 'ensure-error': sys.exit(1)
    print('{"version":1,"ready":true}')
    sys.exit(0)
if mode == 'slow': time.sleep(2)
if mode == 'delay': time.sleep(.12)
if mode == 'error': print('synthetic failure', file=sys.stderr); sys.exit(1)
if mode == 'oversized': print('x' * 10000); sys.exit(0)
if mode == 'stderr': print('x' * 10000, file=sys.stderr); sys.exit(1)
if mode == 'malformed': print('{bad'); sys.exit(0)
r = {'provider':'claude', 'session_id':'root', 'generation':18446744073709551615,
     'relation':'root', 'root_id':'root', 'state':'running', 'aggregate_state':'waiting',
     'running_descendants':50, 'unresolved_requests':2, 'attention_unknown':True,
     'unresolved_count_exact':False, 'request_ids':['one', 'two'], 'last_event_at':'2026-10-03T00:00:00Z',
     'liveness':'unknown', 'ordering':'best_effort', 'classification':'resolved', 'name':'same', 'cwd':'/demo'}
revision = 'epoch:9007199254740993:scope-' + arg('--provider', 'all')
if mode == 'restart': revision = 'new-' + revision
if '--session' in args:
    if arg('--session') == 'missing':
        print(json.dumps({'version':1, 'revision':revision, 'error_code':'not_found'})); sys.exit(0)
    print(json.dumps({'version':1,'revision':revision,'complete':True,'session':r})); sys.exit(0)
if mode == 'unchanged-bad' or (mode in ('unchanged', 'delay', 'slow') and arg('--revision') == revision):
    print(json.dumps({'version':1,'revision':revision,'unchanged':True})); sys.exit(0)
reply = {'version':1,'revision':revision,'complete':True,'roots':[r]}
if mode == 'empty': reply.pop('roots')
if mode == 'duplicate': reply['roots'].append(r.copy())
if mode == 'incomplete': reply.pop('complete')
if mode == 'version': reply['version']=2
if mode == 'missing-field': del r['unresolved_count_exact']
if mode == 'unknown': r['aggregate_state']='future-state'
print(json.dumps(reply))
