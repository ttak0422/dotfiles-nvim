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

Session rows retain state and counts before truncating the name:

- `run`, `idle`, `end`, `wait`, `?`: aggregate state; unknown states stay unknown.
- `W2+?`: two known unresolved requests, with an unknown remainder. `W0` is exact zero.
- `R50`: fifty running descendants, not the total number of children.
- `~` before the name: hierarchy is unresolved. It does not change backend identity
  or treat an unclassified session as a proven root. Enter shows the original fields.
- `—` after a provider: no observations for it in this snapshot. A connecting/error
  snapshot with no data does not claim the provider is empty.
- `+2 more · wait 1 · a`: two summary entries hidden, one with waiting/unknown
  attention. This count is entries, not requests. `a` opens the full grouped list.

The row budget is shared across providers (10 by default); headers and overflow
indicators are additional. Claude then Codex retain the familiar order, other
provider names follow separately, and IDs stay sorted within each group. An
uncertain Codex hierarchy is still shown under Codex. No child-tree API or
waiting-priority reordering is introduced by this presentation change.

## Actual rendered examples

These are lines read from the real pinned Komado buffer (commit `8123dd6`), using
anonymous snapshots and padding=1. `before` uses dotfiles-nvim main
`90bbd9558f7495545bae40a9c1f5c84ccb748e9f`; `after` uses this implementation.
Color/highlight is omitted; text is not hand-written mock UI. Sidebar widths are
32 and 40 columns. The complete [before](../tests/mimori/snapshots/before.txt) and
[after](../tests/mimori/snapshots/after.txt) fixtures cover 11 cases at both widths,
including Japanese names, paused polling and an unknown provider.

### empty / sidebar 32

Before:

```text
 mimori · connected
 No classified roots
```

After:

```text
 ● Claude —
 ● Codex —
```

### connected-idle / sidebar 32

Before:

```text
 mimori · connected
 review-api-change · idle · ch…
```

After:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex —
```

### populated / sidebar 32

Before:

```text
 mimori · connected
 review-api-change · idle · ch…
 implement-provider-layout · r…
```

After:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex
 run W0 R50 implement-provider…
```

### unknown-wait / sidebar 32

Before:

```text
 mimori · connected
 review-api-change · idle · ch…
 Unclassified: 1 · a: all
```

After:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex
 wait W2+? R0 ~ 12345678-1234-…
```

### connecting / sidebar 32

Before:

```text
 mimori · loading
```

After:

```text
 ◌ Claude
 ◌ Codex
```

### disconnected / sidebar 32

Before:

```text
 mimori · error
 collector socket unavailable
```

After:

```text
 ! Claude
 ! Codex
```

### error-retained / sidebar 32

Before:

```text
 mimori · error (retained)
 CLI exit 1: cannot connect to…
 review-api-change · idle · ch…
 implement-provider-layout · r…
 Unclassified: 1 · a: all
```

After:

```text
 ! Claude
 idle W0 R0 review-api-change
 ! Codex
 wait W2+? R0 ~ 12345678-1234-…
 run W0 R50 implement-provider…
```

### overflow / sidebar 32

Before:

```text
 mimori · connected
 task-01 · idle · child 0 · wa…
 task-02 · idle · child 0 · wa…
 task-03 · idle · child 0 · wa…
 task-04 · idle · child 0 · wa…
 task-05 · idle · child 0 · wa…
 task-06 · idle · child 0 · wa…
 task-07 · idle · child 0 · wa…
 task-08 · idle · child 0 · wa…
 task-09 · idle · child 0 · wa…
 task-10 · idle · child 0 · wa…
 +4 hidden roots · 1 waiting/u…
```

After:

```text
 ● Claude
 idle W0 R0 task-01
 idle W0 R0 task-03
 idle W0 R0 task-05
 idle W0 R0 task-07
 idle W0 R0 task-09
 +2 more · wait 1 · a
 ● Codex
 idle W0 R0 task-02
 idle W0 R0 task-04
 idle W0 R0 task-06
 idle W0 R0 task-08
 idle W0 R0 task-10
 +2 more · wait 0 · a
```

### unknown-wait / sidebar 40

Before:

```text
 mimori · connected
 review-api-change · idle · child 0 · …
 Unclassified: 1 · a: all
```

After:

```text
 ● Claude
 idle W0 R0 review-api-change
 ● Codex
 wait W2+? R0 ~ 12345678-1234-1234-123…
```

## Reproduce and verify

```sh
MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py

# Regenerate both actual buffers for review:
MIMORI_TEST_NVIM=/absolute/unwrapped/nvim \
MIMORI_KOMADO=/absolute/pinned-komado \
python3 tests/mimori/run.py --snapshots /tmp/mimori-sidebar-previews
```

The default run checks the rendered after fixture. Tests cover provider grouping,
shared row budgets, width bounds, visible counts/uncertainty, status glyph width,
selection across group growth, unresolved detail fields, full transport diagnostics,
hidden status/detail/all windows and existing client redraw/lifecycle behavior.
Neovim's complete aarch64-darwin derivation evaluates successfully; the full editor
closure was not rebuilt or activated for this change. No provider hooks were edited.
