"""Full-profile UI benchmark. Run with a Python environment containing pynvim.

python benchmark.py BASELINE_NVIM CANDIDATE_NVIM [REPETITIONS=2]
Each editor gets isolated HOME/XDG directories and synthetic temporary files.
Results are JSON lines. This is an observational benchmark, not a timing CI gate.
"""

import json
import os
from pathlib import Path
import signal
import sys
import tempfile

import pynvim

def timeout(_signum, _frame):
    raise TimeoutError("benchmark editor timed out")

signal.signal(signal.SIGALRM, timeout)

CODE = {
    "lua": ["local value = {1, 2, 3}", "for _, v in ipairs(value) do", "  print(v)", "end"],
    "vim": ["let g:value = 42", "function! Hello()", "  echo g:value", "endfunction"],
    "python": ["def greet(name):", "    value = [1, 2, 3]", '    return f"hello {name}"', 'print(greet("world"))'],
    "bash": ["#!/usr/bin/env bash", 'value="hello"', 'for x in a b c; do echo "$x"; done', 'printf "%s\\n" "$value"'],
    "javascript": ["const value = [1, 2, 3];", "function greet(name) {", "  return `hello ${name}`;", "}"],
    "typescript": ["type Person = { name: string };", "function greet(p: Person): string {", "  return `hello ${p.name}`;", "}"],
    "json": ["{", '  "name": "example",', '  "enabled": true', "}"],
    "html": ['<div class="container">', "  <span>hello</span>", "  <script>const x = 1;</script>", "</div>"],
    "yaml": ["name: example", "enabled: true", "values:", "  - hello"],
    "nix": ["{ config, pkgs, ... }:", "{", "  environment.systemPackages = [ pkgs.git ];", "}"],
}
normal = []
for i in range(100):
    lang = list(CODE)[i % len(CODE)]
    normal.extend([f"## Section {i}", "Use `project.start()` with **options** and [documentation](target.md).", "", "```" + lang, *CODE[lang], "```", ""])
dense = ["Use `project.start({ value: true })` and **bold** [link](target.md). " * 10] * 900 + normal[:100]
script = Path(__file__).with_name("benchmark.lua").read_text()
for run in range(int(sys.argv[3]) if len(sys.argv) > 3 else 2):
    # Alternate order to reduce a simple thermal/order bias.
    profiles = list(zip(("baseline", "candidate"), sys.argv[1:3]))
    if run % 2:
        profiles.reverse()
    for label, binary in profiles:
        for case, lines in (("normal", normal), ("dense", dense)):
            with tempfile.TemporaryDirectory(prefix="v3-markdown-benchmark-") as tmp:
                env = os.environ.copy()
                cwd = os.getcwd()
                os.chdir(tmp)
                for key in ("HOME", "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME"):
                    directory = Path(tmp) / key.lower()
                    directory.mkdir()
                    os.environ[key] = str(directory)
                path = Path(tmp) / "fixture.md"
                path.write_text("\n".join(lines) + "\n")
                signal.alarm(180)
                nvim = pynvim.attach("child", argv=[binary, "--embed", "--headless", "-n", "-i", "NONE"])
                try:
                    print(f"{label}/{case}/{run}: startup", file=sys.stderr, flush=True)
                    assert nvim.exec_lua("return package.loaded.divine ~= nil")
                    print(f"{label}/{case}/{run}: attach UI", file=sys.stderr, flush=True)
                    nvim.ui_attach(120, 40, rgb=True, ext_linegrid=True)
                    print(f"{label}/{case}/{run}: actions", file=sys.stderr, flush=True)
                    result = nvim.exec_lua(script, str(path), case)
                    result.update(profile=label, run=run, case=case, bytes=path.stat().st_size, lines=len(lines))
                    print(json.dumps(result), flush=True)
                finally:
                    try:
                        signal.alarm(10)
                        nvim.command("qa!")
                    except EOFError:
                        pass
                    nvim.close()
                    signal.alarm(0)
                    os.chdir(cwd)
                    os.environ.clear()
                    os.environ.update(env)
