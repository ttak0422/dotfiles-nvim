#!/usr/bin/env python3
"""Exercise registration examples against pinned mimori, never installed hooks."""
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import time
import tomllib

ROOT = Path(__file__).resolve().parents[2]
MIMORI = str(Path(os.environ['MIMORI_BIN']).resolve(strict=True))
# Intersection of mimori c5b0d92 and the documented provider event contracts.
COMMON = {
    'SessionStart': 'identity', 'UserPromptSubmit': 'turn_start',
    'PreToolUse': 'running', 'PermissionRequest': 'attention_unknown',
    'PostToolUse': 'request_resolved', 'PreCompact': 'running',
    'PostCompact': 'running', 'SubagentStart': 'turn_start',
    'SubagentStop': 'idle', 'Stop': 'idle', 'SessionEnd': 'ended',
}
KINDS = {
    'codex': COMMON,
    'claude': COMMON | {'PostToolUseFailure': 'request_resolved',
                        'Elicitation': 'request_open',
                        'ElicitationResult': 'request_resolved',
                        'Notification': 'attention_unknown'},
}
COMMANDS = {}
for provider in KINDS:
    directory = ROOT / f'v2/scripts/{provider}-hooks'
    example = directory / ('settings.example.json' if provider == 'claude' else 'config.example.toml')
    config = json.loads(example.read_text()) if provider == 'claude' else tomllib.loads(example.read_text())
    assert set(config) == {'hooks'}
    assert set(config['hooks']) == set(KINDS[provider]), provider
    COMMANDS[provider] = {}
    for event, groups in config['hooks'].items():
        assert len(groups) == 1 and len(groups[0]['hooks']) == 1
        group, handler = groups[0], groups[0]['hooks'][0]
        assert set(handler) == {'type', 'command', 'timeout'}
        assert handler['type'] == 'command' and handler['timeout'] == 5
        wrapper = f'/absolute/path/to/dotfiles-nvim/v2/scripts/{provider}-hooks/komado-{provider}-hook.sh'
        assert shlex.split(handler['command']) == ['MIMORI_BIN=/absolute/path/to/mimori', wrapper]
        matcher = group.get('matcher')
        if event == 'Notification':
            assert matcher == 'permission_prompt|elicitation_dialog'
            for kind in ('permission_prompt', 'elicitation_dialog'):
                assert re.fullmatch(matcher, kind)
            for kind in ('idle_prompt', 'auth_success', 'elicitation_url_dialog',
                         'elicitation_complete', 'agent_needs_input'):
                assert not re.fullmatch(matcher, kind), kind
        elif event in ('SessionStart', 'UserPromptSubmit', 'Stop', 'SessionEnd'):
            assert matcher is None
        else:
            assert matcher == '*'
        COMMANDS[provider][event] = handler['command'].replace('/absolute/path/to/mimori', MIMORI).replace(
            '/absolute/path/to/dotfiles-nvim', str(ROOT))


def payload(provider, event, session, **extra):
    value = {'session_id': session, 'hook_event_name': event, 'cwd': '/anonymous',
             'transcript_path': None if provider == 'codex' else '/missing/DO_NOT_STORE'}
    if event != 'SessionEnd':
        value['permission_mode'] = 'default'
        if provider == 'codex':
            value['model'] = 'example'
            if event != 'SessionStart':
                value['turn_id'] = 'turn-example'
    if event == 'SessionStart': value['source'] = 'startup'
    if event == 'SessionEnd': value['reason'] = 'other'
    if event == 'UserPromptSubmit': value['prompt'] = 'DO_NOT_STORE'
    if event in ('PreToolUse', 'PermissionRequest', 'PostToolUse', 'PostToolUseFailure'):
        value.update(tool_name='Bash', tool_input={'command': 'DO_NOT_STORE'})
        # Ordinary PermissionRequest has no correlation ID in either provider.
        if event != 'PermissionRequest': value['tool_use_id'] = 'unrelated-tool'
        if event == 'PostToolUse': value['tool_response'] = 'DO_NOT_STORE'
        if event == 'PostToolUseFailure': value['error'] = 'DO_NOT_STORE'
    if event in ('PreCompact', 'PostCompact'): value['trigger'] = 'auto'
    if event in ('SubagentStart', 'SubagentStop'): value.update(agent_id='worker', agent_type='Explore')
    if event in ('Stop', 'SubagentStop'):
        value.update(stop_hook_active=False, last_assistant_message='DO_NOT_STORE')
    if event in ('Elicitation', 'ElicitationResult'):
        value.update(mcp_server_name='example', elicitation_id='ask', mode='form')
        if event == 'Elicitation': value['message'] = 'DO_NOT_STORE'
        else: value.update(action='accept', content={'secret': 'DO_NOT_STORE'})
    if event == 'Notification': value.update(notification_type='permission_prompt', message='DO_NOT_STORE')
    return value | extra


def wait(fn):
    deadline = time.monotonic() + 6
    while time.monotonic() < deadline:
        result = fn()
        if result: return result
        time.sleep(.025)
    raise AssertionError('hook snapshot deadline expired')


with tempfile.TemporaryDirectory(prefix='mh-') as temporary:
    temp = Path(temporary)
    state = temp / 'state'
    state.mkdir(mode=0o700)
    env = os.environ | {'HOME': str(temp), 'XDG_STATE_HOME': str(temp / 'xdg'),
                        'MIMORI_STATE_DIR': str(state), 'PATH': '/usr/bin:/bin'}
    env.pop('MIMORI_BIN', None)  # The example must supply it independently of Neovim/PATH.
    env.pop('MIMORI_GENERATION', None)

    def emit(provider, event, session, **extra):
        result = subprocess.run(COMMANDS[provider][event], shell=True, executable='/bin/sh',
                                input=json.dumps(payload(provider, event, session, **extra)),
                                env=env, capture_output=True, text=True, timeout=6)
        assert result.returncode == 0, (provider, event, result.stderr)
        assert result.stdout == '' and result.stderr == '', (provider, event)

    # Every registered event reaches the correct provider, including both attention notifications.
    expected = set()
    for provider, kinds in KINDS.items():
        for event, kind in kinds.items():
            notifications = ('permission_prompt', 'elicitation_dialog') if event == 'Notification' else (None,)
            for notification in notifications:
                before = set((state / 'spool').glob('*.json'))
                session = f'{provider}-{event}-{notification or "probe"}'
                emit(provider, event, session, **({'notification_type': notification} if notification else {}))
                files = set((state / 'spool').glob('*.json')) - before
                assert len(files) == 1
                raw = files.pop().read_text()
                record = json.loads(raw)
                assert 'DO_NOT_STORE' not in raw
                assert (record['provider'], record['kind'], record['generation']) == (provider, kind, 1)
                expected.add((provider, record['session_id']))
    assert not (state / 'query.sock').exists(), 'hook started a daemon'

    def query():
        result = subprocess.run([MIMORI, 'query', '--state-dir', str(state)], env=env,
                                capture_output=True, text=True, timeout=3)
        return json.loads(result.stdout) if result.returncode == 0 else None

    def rows():
        snapshot = query() or {}
        return {(row['provider'], row['session_id']): row
                for section in ('roots', 'unclassified') for row in snapshot.get(section, [])}

    def row_matches(provider, session, **fields):
        row = rows().get((provider, session))
        return row if row and all(row.get(key) == value for key, value in fields.items()) else None

    # Own a foreground daemon so cleanup never targets an installed collector.
    daemon = subprocess.Popen([MIMORI, 'daemon', '--state-dir', str(state)], env=env,
                              stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        wait(lambda: expected == set(rows()))
        for provider in KINDS:
            session = f'flow-{provider}'
            emit(provider, 'SessionStart', session)
            emit(provider, 'UserPromptSubmit', session)
            row = wait(lambda: row_matches(provider, session, state='running'))
            assert row['relation'] == ('root' if provider == 'claude' else 'unknown')
            assert ('claude' if provider == 'codex' else 'codex', session) not in rows()
            emit(provider, 'PermissionRequest', session)
            wait(lambda: row_matches(provider, session, aggregate_state='waiting', attention_unknown=True,
                                     unresolved_requests=0, unresolved_count_exact=False))
            emit(provider, 'PostToolUse', session)
            emit(provider, 'Stop', session)
            wait(lambda: row_matches(provider, session, state='idle', aggregate_state='waiting', attention_unknown=True))
            emit(provider, 'SessionEnd', session)
            wait(lambda: row_matches(provider, session, state='ended', aggregate_state='ended',
                                     attention_unknown=False, unresolved_count_exact=True))

        emit('claude', 'UserPromptSubmit', 'tree')
        emit('claude', 'SubagentStart', 'tree')
        wait(lambda: row_matches('claude', 'tree', running_descendants=1))
        emit('claude', 'Elicitation', 'tree', agent_id='worker')
        wait(lambda: row_matches('claude', 'tree', aggregate_state='waiting', unresolved_requests=1,
                                 unresolved_count_exact=True))
        emit('claude', 'ElicitationResult', 'tree', agent_id='worker')
        wait(lambda: row_matches('claude', 'tree', aggregate_state='running', unresolved_requests=0))
        emit('claude', 'SubagentStop', 'tree')
        wait(lambda: row_matches('claude', 'tree', running_descendants=0))
        assert not query().get('latest_collector_diagnostic')
    finally:
        daemon.terminate()
        out, err = daemon.communicate(timeout=5)
        assert daemon.returncode == 0 and not (state / 'query.sock').exists(), (out, err)
print('hooks: passed; Claude=15, Codex=11; 27 offline probes; provider routing, '
      'anonymous waits, session end, child elicitation and cleanup verified')
