# Active-first provider sidebar

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

Session rows use herdr-inspired round markers before the counts and name, with
color as the primary state cue. Running, waiting and ended share a filled dot;
idle and unknown use a quieter outline. No icon font is required. Only the marker
is colored, so names and counters keep the normal sidebar foreground. The all
view uses the same markers and colors. K/Enter still exposes the full state text,
including future unknown states; the marker does not replace the backend state.

| State | Glyph / fallback | Default highlight link (typical color) |
| --- | --- | --- |
| Running | ● / * | `MimoriRunning` → `DiagnosticWarn` (yellow) |
| Waiting | ● / * | `MimoriWaiting` → `DiagnosticError` (red/pink) |
| Idle | ○ / o | `MimoriIdle` → `DiagnosticOk` (green) |
| Ended | ● / * | `MimoriEnded` → `DiagnosticInfo` (cyan/blue) |
| Unknown, including future states | ○ / o | `MimoriUnknown` → `Comment` (gray) |

Colors follow the active colorscheme, not fixed RGB values. Override a `Mimori*`
group with `nvim_set_hl` if needed; the adapter uses default links and does not
replace user-defined groups. Changing colorscheme refreshes both sidebar and all
view. As with transport icons, a wider-than-one-cell glyph falls back to ASCII.
The aggregate state comes directly from mimori. Ended history is retained;
idle/unknown sessions are never inferred to have ended.

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

## Active summaries first

The row budget is shared across providers (10 by default); headers and overflow
indicators are additional. Before allocating slots or truncating text, the adapter
partitions each provider's entries into non-ended summaries and ended history.
Claude, Codex, then other provider names retain their familiar group order.
Each partition keeps stable session-ID order in the sidebar and `:MimoriAll`.

A summary moves to the ended partition only when both `state` and
`aggregate_state` are exactly `ended`, `running_descendants` is zero, and there
are no unresolved requests, unknown attention, or inexact request counts.
An ended parent with running, waiting, or unknown descendants stays in the first
partition. Idle, unknown, future states, observation age, and liveness alone do
not lower priority. Roots and unclassified entries follow the same rule without
inventing hierarchy or changing identity.

The shared cap is allocated round-robin across providers in two passes:

1. Allocate to non-ended summaries across every provider
2. Use any remaining slots for ended summaries

For example, twelve ended Claude summaries cannot push the sixth running Codex
summary beyond a ten-row cap. All six Codex summaries receive slots first, leaving
four slots for Claude history. Existing overflow and waiting counts describe only
the omitted summaries, and `a` opens every summary including ended history.
If only ended summaries remain, they still use the available slots. No session or
persistent data is removed, and K/Enter details remain available.

### Parent/child contract limit

The pinned mimori v1 API exposes root aggregates and unclassified entries, not a
complete child list or non-ended-descendant count. An ended parent with only idle
children still reports `aggregate_state=ended`; the adapter cannot distinguish it
from an entirely ended tree without extra queries or an upstream API change.
For this reason the presentation uses lower priority instead of deleting/hiding
all ended summaries. That parent remains available in spare sidebar slots and
always in `:MimoriAll`. This change preserves the backend fields and does not add
child discovery, expiry heuristics, or a mimori patch.

## Actual rendered examples

These are lines read from the real pinned Komado buffer (`8123dd6`), using
anonymous snapshots and padding=1. `before` uses dotfiles-nvim main
`420db159a086f6e56d5d82a5ffeb3f9375e3093d`; `after` uses this implementation.
Text fixtures cannot display the colors; tests also inspect real extmarks for
each state, theme changes, and custom highlight preservation.
The complete [before](../tests/mimori/snapshots/before.txt) and
[after](../tests/mimori/snapshots/after.txt) fixtures cover 16 cases at both
32 and 40 columns, including all states, Japanese names, unknown providers,
retained error snapshots, overflow, and uncertain request counts.

### ended-last / sidebar 32

Before:

```text
 ● Claude
 ● W0 R0 a-ended
 ● W0 R0 b-ended
 ○ W0 R0 x-unknown
 ○ W0 R0 y-idle
 ● W0 R0 z-running
 ● Codex —
```

After:

```text
 ● Claude
 ○ W0 R0 x-unknown
 ○ W0 R0 y-idle
 ● W0 R0 z-running
 ● W0 R0 a-ended
 ● W0 R0 b-ended
 ● Codex —
```

### ended-pressure / sidebar 32

Before:

```text
 ● Claude
 ● W0 R0 a-ended-01
 ● W0 R0 a-ended-02
 ● W0 R0 a-ended-03
 ● W0 R0 a-ended-04
 ● W0 R0 a-ended-05
 +7 more · wait 0 · a
 ● Codex
 ● W0 R0 z-working-01
 ● W0 R0 z-working-02
 ● W0 R0 z-working-03
 ● W0 R0 z-working-04
 ● W0 R0 z-working-05
 +1 more · wait 0 · a
```

After:

```text
 ● Claude
 ● W0 R0 a-ended-01
 ● W0 R0 a-ended-02
 ● W0 R0 a-ended-03
 ● W0 R0 a-ended-04
 +8 more · wait 0 · a
 ● Codex
 ● W0 R0 z-working-01
 ● W0 R0 z-working-02
 ● W0 R0 z-working-03
 ● W0 R0 z-working-04
 ● W0 R0 z-working-05
 ● W0 R0 z-working-06
```

### ended-parent / sidebar 32

Before:

```text
 ● Claude —
 ● Codex
 ● W0 R2 a-ended-parent
```

After:

```text
 ● Claude —
 ● Codex
 ● W0 R2 a-ended-parent
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

# Optional model check using Go and a clean locked mimori c5b0d92 checkout:
MIMORI_TEST_NVIM=/absolute/nvim \
MIMORI_SOURCE=/absolute/pinned-mimori-source \
python3 tests/mimori/priority-model.py
```

Tests use synthetic data only. No provider prompt, installed hook, or running
user daemon is touched. Headless validation covers behavior and highlight
attributes; it does not prove physical terminal font/color appearance on macOS.

The priority suite covers cross-provider and same-provider caps, active/ended
partitions, unclassified summaries, aggregate safety and contradictory quality
signals, overflow waiting counts, retained history, and repeated input shuffles.
The model check runs the unchanged pinned reducer and query code in-process;
it exercises ended parents with running, waiting, unknown, idle, or ended children
and anonymous attention using synthetic events. No daemon or socket is used;
this is a model/adapter contract check, not a live transport integration test.
Hover tests cover terminal-row reordering and late replies; the all view preserves
the selected provider/session identity when that session moves to ended history.
