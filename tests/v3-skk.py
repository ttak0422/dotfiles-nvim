"""Exercise real Neovim input and the packaged Go backend, with isolated XDG dirs."""
import os
import pathlib
import sys
import time

import pynvim


def wait(nvim, predicate, label):
    end = time.monotonic() + 10
    while time.monotonic() < end:
        if predicate():
            return
        time.sleep(0.02)
    raise AssertionError(f"{label}: mode={nvim.eval('mode()')}, lines={nvim.current.buffer[:]}, log={nvim.call('goda#log')}")


def send(nvim, keys):
    nvim.input(keys)
    # Round trip, rather than fixed sleep, followed by explicit state assertions.
    nvim.eval("1")


def start():
    nvim = pynvim.attach("child", argv=[sys.argv[1], "--embed", "--headless", "-n", "-i", "NONE"])
    assert nvim.eval("$NVIM_APPNAME") == "nvim-v3-skk"
    assert nvim.eval("v:errmsg") == ""
    assert nvim.eval("executable(g:['goda_skk#binary'])") == 1
    assert nvim.eval("exists('g:loaded_goda_skk')") == 1
    assert nvim.eval("exists('g:loaded_skkeleton')") == 0
    for mode in ["i", "c", "t"]:
        assert "goda-skk-enable" in nvim.call("maparg", "<C-j>", mode)
    # Offline/prebuilt operation: the integration test intentionally has no Go.
    assert nvim.call("executable", "go") == 0
    return nvim


def stop(nvim):
    try:
        nvim.command("qa!")
    except EOFError:
        pass
    finally:
        nvim.close()


# Each mode is the first SKK use in a new editor, not masked by InsertEnter.
nvim = start()
try:
    send(nvim, "i<C-j>aiueo")
    wait(nvim, lambda: nvim.current.line == "あいうえお", "hiragana input")
    send(nvim, "<Esc>")
    wait(nvim, lambda: nvim.eval("mode()") == "n", "leave insert mode")
    assert not nvim.call("goda_skk#is_enabled")
    nvim.current.buffer[:] = [""]
    send(nvim, "i<C-j>Kanji<Space>")
    wait(nvim, lambda: nvim.current.line.startswith("▼") and len(nvim.current.line) > 1, "EUC-JP dictionary conversion")
    first = nvim.current.line
    send(nvim, "<Space>")
    wait(nvim, lambda: nvim.current.line != first, "next candidate")
    selected = nvim.current.line.removeprefix("▼")
    assert any("\u4e00" <= char <= "\u9fff" for char in selected), selected
    send(nvim, "<C-j><Esc>")
    wait(nvim, lambda: nvim.current.line == selected and nvim.eval("mode()") == "n", "confirm conversion")
    user_dict = pathlib.Path(nvim.eval("$GODA_SKK_STATE_DIR")) / "SKK-JISYO.user"
    wait(nvim, lambda: user_dict.exists() and selected in user_dict.read_text(), "persist learned candidate")
    assert str(user_dict).startswith(os.environ["XDG_STATE_HOME"])
    nvim.current.buffer[:] = [""]
    send(nvim, "i<C-j>aiujk")
    wait(nvim, lambda: nvim.current.line == "あいう" and nvim.eval("mode()") == "n", "jk escape rule")
    assert not nvim.call("goda_skk#is_enabled")
finally:
    stop(nvim)

nvim = start()
try:
    send(nvim, "/<C-j>aiueo")
    wait(nvim, lambda: nvim.call("getcmdline") == "あいうえお", "command-line first use")
    send(nvim, "<Esc>")
    wait(nvim, lambda: nvim.eval("mode()") == "n", "leave command line")
    send(nvim, "i<C-j>Kanji<Space>")
    wait(nvim, lambda: nvim.current.line == "▼" + selected, "reload learned candidate")
    send(nvim, "<C-g><Esc>")
finally:
    stop(nvim)

nvim = start()
try:
    nvim.command("terminal " + os.environ["SKK_TEST_CAT"])
    send(nvim, "i<C-j>aiueo")
    wait(nvim, lambda: "あいうえお" in "\n".join(nvim.current.buffer[:]), "terminal first use")
    send(nvim, "<C-\\><C-n>")
    wait(nvim, lambda: nvim.eval("mode()") == "n", "leave terminal")
    assert not nvim.call("goda_skk#is_enabled")
finally:
    stop(nvim)

print("Goda SKK: insert, conversion, cycling, learning/restart, jk, command-line and terminal passed")
