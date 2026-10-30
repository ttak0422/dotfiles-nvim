"""Run only the manager-owned fixture in temporary XDG directories."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="managed-generation-") as directory:
    temp = Path(directory)
    env = os.environ | {
        "HOME": str(temp / "home"), "XDG_CONFIG_HOME": str(temp / "config"),
        "XDG_DATA_HOME": str(temp / "data"), "XDG_STATE_HOME": str(temp / "state"),
        "XDG_CACHE_HOME": str(temp / "cache"), "VIMINIT": "", "EXINIT": "",
        "GENERATION_POC_ROOT": str(root),
    }
    subprocess.run([os.environ.get("NVIM_BIN", "nvim"), "--headless", "-n", "-u", "NONE", "-i", "NONE",
                    "-l", str(root / "tests/run.lua")], env=env, check=True, timeout=20)
