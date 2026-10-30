#!/usr/bin/env python3
"""Pure Nix evaluation plus isolated Neovim fixtures. No builds or downloads."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
NIX = os.environ.get("NIX_INSTANTIATE", "nix-instantiate")


def evaluate(attribute):
    return subprocess.check_output(
        [NIX, "--eval", "--strict", "--json", str(ROOT / "default.nix"), "-A", attribute],
        text=True,
    )


def rejected(expression, message):
    with tempfile.NamedTemporaryFile(mode="w", suffix=".nix") as file:
        file.write(expression)
        file.flush()
        result = subprocess.run(
            [NIX, "--eval", "--strict", "--json", file.name, "-A", "manifest"],
            capture_output=True, text=True,
        )
    assert result.returncode != 0 and message in result.stderr, result.stderr


def main():
    outputs = {name: evaluate(name) for name in ("manifest", "lua", "handbook")}
    assert outputs == {name: evaluate(name) for name in outputs}, "non-deterministic output"
    manifest = json.loads(outputs["manifest"])
    assert [feature["id"] for feature in manifest["features"]] == ["base", "metrics", "picker"]
    for feature in manifest["features"]:
        for path in (feature["docs"], feature["hooks"], feature["evidence"], *feature["tests"].values()):
            assert (ROOT / path).is_file(), path
    prefix = f"let f = import {ROOT}/config.nix; in import {ROOT}/compile.nix {{ root = {ROOT}; features = "
    rejected(prefix + 'f // { base = f.base // { requires = [ "missing" ]; }; }; }', "invalid schema")
    rejected(prefix + 'f // { base = f.base // { requires = [ "picker" ]; }; }; }', "base -> picker -> base")
    rejected(prefix + 'f // { base = f.base // { typo = true; }; }; }', "unknown field")
    rejected(prefix + 'f // { base = f.base // { scope = "window"; }; }; }', "invalid schema")
    rejected(prefix + 'f // { base = f.base // { hooks = "missing.lua"; }; }; }', "missing/invalid file")
    rejected(prefix + 'f // { base = f.base // { requires = [ "metrics" ]; }; }; }', "invalid schema")
    rejected(prefix + 'f // { base = f.base // { activation = { kind = "command"; command = "PocPick"; }; }; }; }', "duplicate command")
    rejected(prefix + 'f // { base = f.base // { activation = { kind = "startup"; command = "Ignored"; }; }; }; }', "invalid schema")
    rejected(prefix + 'f // { metrics = f.metrics // { updates.events = [ "UnsupportedEvent" ]; }; }; }', "invalid schema")
    print("PASS: deterministic Nix outputs, provenance paths and 9 invalid-schema fixtures", flush=True)

    with tempfile.TemporaryDirectory(prefix="pure-nix-poc-") as directory:
        temp = Path(directory)
        (temp / "plan.lua").write_text(json.loads(outputs["lua"]))
        (temp / "manifest.json").write_text(outputs["manifest"])
        (temp / "handbook.md").write_text(json.loads(outputs["handbook"]))
        env = os.environ | {
            "POC_ROOT": str(ROOT), "POC_PLAN": str(temp / "plan.lua"),
            "HOME": str(temp / "home"), "XDG_CONFIG_HOME": str(temp / "config"),
            "XDG_DATA_HOME": str(temp / "data"), "XDG_STATE_HOME": str(temp / "state"),
            "XDG_CACHE_HOME": str(temp / "cache"), "VIMINIT": "", "EXINIT": "",
        }
        subprocess.run([os.environ.get("NVIM_BIN", "nvim"), "--headless", "-n", "-u", "NONE", "-i", "NONE",
                        "-l", str(ROOT / "tests/runtime.lua")], env=env, check=True, timeout=30)


if __name__ == "__main__":
    main()
