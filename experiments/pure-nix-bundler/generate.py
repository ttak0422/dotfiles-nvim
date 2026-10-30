#!/usr/bin/env python3
"""Materialize pure Nix outputs; this never executes plugin hooks."""
import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent


def outputs():
    result = {}
    for name in ("manifest", "lua", "handbook"):
        result[name] = json.loads(subprocess.check_output([
            os.environ.get("NIX_INSTANTIATE", "nix-instantiate"), "--eval", "--strict", "--json",
            str(ROOT / "default.nix"), "-A", name,
        ], text=True))
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=ROOT / "generated")
    directory = parser.parse_args().out
    directory.mkdir(parents=True, exist_ok=True)
    data = outputs()
    (directory / "manifest.json").write_text(json.dumps(data["manifest"], sort_keys=True, indent=2) + "\n")
    (directory / "plan.lua").write_text(data["lua"])
    (directory / "handbook.md").write_text(data["handbook"])
    print(directory)
