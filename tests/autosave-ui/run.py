#!/usr/bin/env python3
"""Real ui2 + pinned plugins, with isolated stdpaths and a synthetic Markdown file."""
import argparse
import json
import os
from pathlib import Path
import select
import subprocess
import tempfile
import time
import msgpack

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--trace-dir', type=Path)
args = parser.parse_args()
if args.trace_dir:
    args.trace_dir.mkdir(parents=True, exist_ok=True)


class Editor:
    def __init__(self, temp):
        self.file = temp / 'synthetic.md'
        env = os.environ | {
            'AUTOSAVE_UI_ROOT': str(root), 'AUTOSAVE_UI_FILE': str(self.file),
            'NVIM_LOG_FILE': str(temp / 'nvim.log'), 'HOME': str(temp / 'home'),
        } | {f'XDG_{name}_HOME': str(temp / name.lower())
             for name in ('CONFIG', 'DATA', 'STATE', 'CACHE')}
        self.process = subprocess.Popen(
            [os.environ['AUTOSAVE_UI_NVIM'], '--embed', '-u', 'NONE', '-i', 'NONE', '-n'],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
        self.unpacker = msgpack.Unpacker(raw=False)
        self.sequence, self.redraw = 0, []

    def setup(self):
        self.request('nvim_ui_attach', 100, 32,
                     {'rgb': True, 'ext_linegrid': True, 'ext_multigrid': True})
        self.lua('dofile(...)', str(root / 'tests/autosave-ui/init.lua'))
        self.wait(.1)

    def events(self, timeout):
        if not select.select([self.process.stdout], [], [], timeout)[0]:
            return []
        data = os.read(self.process.stdout.fileno(), 1024 * 1024)
        if not data:
            raise RuntimeError(self.process.stderr.read().decode())
        self.unpacker.feed(data)
        events = list(self.unpacker)
        for event in events:
            if event[0] == 2 and event[1] == 'redraw':
                self.redraw.extend(e for e in event[2]
                                   if e[0] in ('grid_cursor_goto', 'mode_change', 'win_float_pos'))
        return events

    def request(self, method, *params):
        self.sequence += 1
        self.process.stdin.write(msgpack.packb([0, self.sequence, method, params], use_bin_type=True))
        self.process.stdin.flush()
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            for event in self.events(max(0, deadline - time.monotonic())):
                if event[0] == 1 and event[1] == self.sequence:
                    assert not event[2], event[2]
                    return event[3]
        raise TimeoutError(method)

    def lua(self, code, *params):
        return self.request('nvim_exec_lua', code, params)

    def wait(self, seconds):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            self.events(max(0, deadline - time.monotonic()))

    def input(self, keys):
        self.request('nvim_input', keys)
        self.wait(.02)

    def close(self):
        self.process.terminate()
        self.process.wait(timeout=3)


for case in ('normal', 'insert', 'cmdline', 'command-after-save', 'nested-cmdline'):
    with tempfile.TemporaryDirectory(prefix='autosave-ui-') as directory:
        editor = Editor(Path(directory))
        try:
            editor.setup()
            editor.input('A changed<Esc>')
            if case == 'insert':
                editor.input('a')
            elif case in ('cmdline', 'nested-cmdline'):
                editor.input(':echo "pending"')
            editor.lua("snapshot('before_timer')")
            # Poll for the real timer instead of assuming a configured debounce duration.
            for _ in range(100):
                if editor.lua('return not vim.bo[document].modified'):
                    break
                editor.wait(.02)
            else:
                raise AssertionError('autosave did not finish')
            if case == 'command-after-save':
                editor.input(':echo "manual message"<CR>')
            elif case == 'nested-cmdline':
                editor.input('<C-r>=')
                editor.input('<Esc>')
                config = editor.lua('return vim.api.nvim_win_get_config(require("vim._core.ui2").wins.cmd)')
                assert config['relative'] == 'editor', 'outer cmdline lost its centered position'
            # Includes the previous 1250 ms cleaning deadline.
            editor.wait(1.4)
            editor.lua("snapshot('after_timer')")
            trace = editor.lua('return trace')
            before = next(e for e in trace if e['event'] == 'before_timer')
            after = trace[-1]
            assert after['win'] == before['win'] and after['ft'] == 'markdown', trace
            assert after['cursor'] == before['cursor'], trace
            assert after['mode'] == before['mode'] and after['cmd'] == before['cmd'], trace
            assert editor.file.read_text() == 'synthetic document changed\n'
            assert sum(e['event'] == 'BufWritePost' for e in trace) == 1
            assert not any(e['event'] in ('notify', 'nvim_set_current_win') for e in trace), trace
            assert not any(e['event'] == 'msg_show' and 'AutoSave:' in str(e['extra']) for e in trace)
            assert editor.lua('return require("auto-save.config").opts.execution_message.cleaning_interval') == 0
            if case == 'command-after-save':
                assert any(e['event'] == 'msg_show' and 'manual message' in str(e['extra']) for e in trace)
                editor.lua('vim.notify("explicit notification")')
                editor.wait(.05)
                assert editor.lua('return vim.tbl_contains(vim.tbl_map(function(e) return e.event end, trace), "notify")')
            if args.trace_dir:
                (args.trace_dir / f'{case}.json').write_text(json.dumps(
                    {'trace': editor.lua('return trace'), 'redraw': editor.redraw}, indent=2,
                    default=lambda value: value.hex() if isinstance(value, bytes) else str(value)))
            print('PASS ' + case, flush=True)
        finally:
            editor.close()
