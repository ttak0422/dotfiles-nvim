# Compact provider sidebar

The shared collector connection is shown as one cell on each provider heading:

| Glyph | ASCII fallback | Meaning |
| --- | --- | --- |
| ● | + | Connected to the collector; individual agents may still be idle or unknown |
| ◌ | ~ | Initial connection/startup in progress |
| ○ | - | Client polling paused; observations, if any, are retained |
| ! | ! | Transport/startup error, missing executable, or incompatible response |

These are plain Unicode characters, not emoji sequences or Nerd Font glyphs.
If Neovim measures a glyph as wider than one cell (`ambiwidth=double`, for example),
the ASCII fallback is used. No font installation is needed. `?` or `:MimoriStatus`
shows full transport status, retained-snapshot labeling, diagnostics and this legend.
A historical collector diagnostic remains available there independently of transport
health; it does not falsely mark a connected collector as disconnected.

Session rows use one colored state icon before the counts and name. Both color
and shape carry the state; no icon font is required. Only the state icon is colored,
so names and counters keep the normal sidebar foreground. The all view uses the
same icons and colors.

| State | Glyph / fallback | Default highlight link (typical color) |
| --- | --- | --- |
| Running | ▶ / > | `MimoriRunning` → `DiagnosticOk` (green) |
| Waiting | ◆ / ! | `MimoriWaiting` → `DiagnosticWarn` (yellow) |
| Idle | ○ / - | `MimoriIdle` → `Comment` (gray) |
| Ended | ■ / x | `MimoriEnded` → `NonText` (dim gray) |
| Unknown, including future states | ? / ? | `MimoriUnknown` → `DiagnosticInfo` (blue) |

Colors follow the active colorscheme, not fixed RGB values. Override a `Mimori*`
group with `nvim_set_hl` if needed; the adapter uses default links and does not
replace user-defined groups. Changing colorscheme refreshes both sidebar and all
view. As with transport icons, a wider-than-one-cell glyph falls back to ASCII.
The aggregate state comes directly from mimori: this change does not hide ended
sessions or infer that idle/unknown sessions have ended.

- `W2+?`: two known unresolved requests, with an unknown remainder. `W0` is exact zero
- `R50`: fifty running descendants, not the total number of children
- `~` before the name: hierarchy is unresolved. It does not change backend identity
  or treat an unclassified session as a proven root. K or Enter shows the original fields
- `—` after a provider: no observations for it in this snapshot. A connecting/error
  snapshot with no data does not claim the provider is empty
- `+2 more · wait 1 · a`: two summary entries hidden, one with waiting/unknown
  attention. This count is entries, not requests. `a` opens the full grouped list

## Detail keys

- `K` on an agent row: open its existing detail fields in a rounded, wrapped hover,
  leaving focus in the sidebar
- `K` again on the same agent: focus the existing hover to scroll it
- `K` while focused in the hover: return to the sidebar
- `q` or Escape while focused in the hover: close it
- `r` while focused in the hover: refresh
- Enter: keep the existing separate detail split

The popup is at most 80 columns × 20 rows and is clamped to the available editor
space. It closes when the sidebar cursor moves, its selected identity changes,
the sidebar is hidden/replaced/closed, another editor window/tab is entered, or
the editor is resized. Pressing K after resizing opens it at the new size.
Closing cancels pending detail work; late or superseded responses cannot reopen
or overwrite a newer popup. K is buffer/row-local; normal LSP mappings in editing
buffers are untouched. Provider and overflow rows do not open an agent hover.

The row budget is shared across providers (10 by default); headers and overflow
indicators are additional. Claude then Codex retain the familiar order, other
provider names follow separately, and IDs stay sorted within each group. An
uncertain Codex hierarchy is still shown under Codex. No child-tree API or
waiting-priority reordering is introduced by this presentation change.

## Actual rendered examples

These are lines read from the real pinned Komado buffer (`8123dd6`), using
anonymous snapshots and padding=1. `before` uses dotfiles-nvim main
`41824d5a8ad26f0d234d1aa821991f2c18eafddf`; `after` uses this implementation.
Text fixtures cannot display the colors; tests also inspect real extmarks for
each state, theme changes, and custom highlight preservation.
The complete [before](../tests/mimori/snapshots/before.txt) and
[after](../tests/mimori/snapshots/after.txt) fixtures cover 12 cases at both
32 and 40 columns, including all states, Japanese names, unknown providers,
retained error snapshots, overflow, and uncertain request counts.

### populated / sidebar 32

Before:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex
 run W0 R50 implement-provider…
```

After:

```text
 ● Claude
 ○ W0 R0 review-api-change
 ● Codex
 ▶ W0 R50 implement-provider-l…
```

### unknown-wait / sidebar 40

Before:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex
 wait W2+? R0 ~ 12345678-1234-1234-123…
```

After:

```text
 ● Claude
 ○ W0 R0 review-api-change
 ● Codex
 ◆ W2+? R0 ~ 12345678-1234-1234-1234-1…
```

### all-states / sidebar 32

Before:

```text
 ● Claude
 run W0 R0 a-running
 wait W0 R0 b-waiting
 idle W0 R0 c-idle
 end W0 R0 d-ended
 ? W0 R0 e-unknown
 ? W0 R0 f-future
 ● Codex —
```

After:

```text
 ● Claude
 ▶ W0 R0 a-running
 ◆ W0 R0 b-waiting
 ○ W0 R0 c-idle
 ■ W0 R0 d-ended
 ? W0 R0 e-unknown
 ? W0 R0 f-future
 ● Codex —
```

## Reproduce

Use a clean Neovim (0.11.4 verified) and the pinned Komado checkout:

```sh
MIMORI_TEST_NVIM=/absolute/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py

MIMORI_TEST_NVIM=/absolute/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py --snapshots /tmp/mimori-sidebar-previews
```

Tests use synthetic data only. No provider prompt, installed hook, or running
user daemon is touched. Headless validation covers behavior and highlight
attributes; it does not prove physical terminal font/color appearance on macOS.
