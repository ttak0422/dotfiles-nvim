#!/usr/bin/env python3
"""Verify terminal-parent ordering using the pinned in-process mimori reducer.

Requires MIMORI_SOURCE (clean checkout at the locked revision), Go, and Neovim.
No daemon, socket, database, or installed provider state is used.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE, NVIM = Path(os.environ['MIMORI_SOURCE']).resolve(), os.environ['MIMORI_TEST_NVIM']
revision = json.loads((ROOT / 'flake.lock').read_text())['nodes']['v2-mimori']['locked']['rev']
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=SOURCE, text=True).strip() == revision
assert not subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=all', '--',
    'internal/mimori', 'go.mod', 'go.sum'], cwd=SOURCE, text=True).strip(), 'mimori source is not clean'
BRIDGE = r'''package main
import (
    "encoding/json"
    "os"
    "github.com/ttak0422/mimori/internal/mimori"
)
func main() {
    var events []mimori.Event
    if err := json.NewDecoder(os.Stdin).Decode(&events); err != nil { panic(err) }
    for _, event := range events { if err := event.Validate(); err != nil { panic(err) } }
    snapshot := mimori.Snapshot{Revision: "test", Sessions: mimori.Reduce(events)}
    output := map[string]mimori.Response{
        "summary": snapshot.Query(mimori.Query{Version: 1}),
        "child": snapshot.Query(mimori.Query{Version: 1, Provider: "codex", Session: "child-idle"}),
    }
    if err := json.NewEncoder(os.Stdout).Encode(output); err != nil { panic(err) }
}
'''
with tempfile.TemporaryDirectory(prefix='mimori-priority-') as temporary:
    temp = Path(temporary)
    env = os.environ | {'HOME': str(temp / 'home'), 'XDG_STATE_HOME': str(temp / 'xdg-state'),
        'XDG_DATA_HOME': str(temp / 'data'), 'XDG_CACHE_HOME': str(temp / 'cache'),
        'MIMORI_TEST_ROOT': str(ROOT), 'MIMORI_PRIORITY_SNAPSHOT': str(temp / 'snapshot.json')}
    for name in ('home', 'xdg-state/nvim', 'data', 'cache'):
        (temp / name).mkdir(parents=True, exist_ok=True)

    events = []

    def ingest(session, kind, relation='root', **extra):
        event = {'version': 1, 'event_id': session + '-' + kind, 'provider': 'codex',
            'session_id': session, 'generation': 1, 'seq': 1, 'relation': relation,
            'kind': kind, 'observed_at': '2026-10-07T00:00:00Z', **extra}
        events.append(event)

    kinds = {'running': 'running', 'waiting': 'request_open', 'unknown': 'identity',
        'attention': 'attention_unknown', 'idle': 'idle', 'ended': 'ended'}
    for name, kind in kinds.items():
        parent = 'parent-' + name
        ingest(parent, 'ended')
        ingest('child-' + name, kind, 'child', parent_id=parent, parent_generation=1,
            **({'request_id': 'permission'} if name == 'waiting' else {}))
    ingest('standalone-idle', 'idle')
    ingest('standalone-unknown', 'identity')
    # The internal package is importable only from within its module. The
    # bridge lives in a temporary untracked folder and is removed afterward.
    with tempfile.TemporaryDirectory(prefix='priority-test-', dir=SOURCE) as bridge:
        main = Path(bridge) / 'main.go'
        main.write_text(BRIDGE)
        response = subprocess.run(['go', 'run', str(main)], cwd=SOURCE, env=env,
            input=json.dumps(events), capture_output=True, text=True, check=True, timeout=120)
        output = json.loads(response.stdout)
        data = output['summary']
        rows = {row['session_id']: row for row in data['roots']}
        for name in kinds:
            row = rows['parent-' + name]
            assert row['state'] == 'ended'
            expected = {'attention': 'waiting', 'idle': 'ended'}.get(name, name)
            assert row['aggregate_state'] == expected, row
        assert rows['parent-running']['running_descendants'] == 1
        assert rows['parent-waiting']['unresolved_requests'] == 1
        assert not rows['parent-attention']['unresolved_count_exact']
        # The v1 summary cannot distinguish an ended parent with an idle child
        # from an entirely ended tree. Verify that boundary rather than infer it.
        child = output['child']
        assert child['session']['state'] == 'idle'
        (temp / 'snapshot.json').write_text(json.dumps(data))
        subprocess.run([NVIM, '--clean', '--headless', '-u', 'NONE', '-i', 'NONE',
            '-l', str(ROOT / 'tests/mimori/priority.lua')], env=env, check=True, timeout=15)
        print('priority-model: passed; mimori ' + revision[:8] + '; ended parents with running/waiting/unknown/idle/ended children; anonymous attention; v1 idle-child boundary verified')
