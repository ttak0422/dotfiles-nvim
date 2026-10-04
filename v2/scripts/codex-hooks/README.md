# Codex hook bridge

`komado-codex-hook.sh` now forwards stdin to `mimori hook --provider codex`.
It performs bounded durable ingest only. It does not inspect session indexes,
transcripts, or processes, write legacy JSON, start a daemon, or print decisions.
Mimori has a two-second ingestion watchdog; configure an outer provider timeout.

Install `mimori` on the hook process PATH or set `MIMORI_BIN` to its absolute
path. Optional `MIMORI_STATE_DIR` selects the client's absolute private state
directory. `MIMORI_GENERATION` defaults to 1 and must change for a verified new
incarnation. Raw hooks have best-effort ordering. Anonymous waits remain visibly
inexact; Codex sessions without proven parentage remain in the all-view's
Unclassified section.

## Registration (Codex CLI 0.159.2 / mimori c5b0d92)

Use [config.example.toml](config.example.toml) as the **owned hook fragment** for
`~/.codex/config.toml`, not as a replacement config. This version supports inline
`[[hooks.Event]]` / `[[hooks.Event.hooks]]` arrays; a separate `hooks.json` is not
required for these handlers. Replace `/absolute/path/to/mimori` with the pinned
executable and `/absolute/path/to/dotfiles-nvim` with this checkout. Each command
sets `MIMORI_BIN` independently of Neovim and uses a five-second outer timeout.
If you override the client's state directory, set `MIMORI_STATE_DIR` in these
commands (or the provider environment) to the same absolute private directory.

Merge one owned handler per event, replacing old Komado handlers rather than
appending duplicates. Preserve unrelated TOML/JSON/plugin hooks and other config.
Review changed commands in Codex's normal `/hooks` flow; do not copy or manufacture
`[hooks.state]` trusted hashes. The tracked fragment does not automatically edit
installed config or grant hook trust.

The example covers SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest,
PostToolUse, PreCompact, PostCompact, SubagentStart, SubagentStop, Stop and
SessionEnd. Codex 0.159.2 does **not** expose PostToolUseFailure, Notification,
Elicitation or ElicitationResult, even though mimori supports some of them for
Claude. Conversely, Codex's Interrupt is not accepted by this pinned mimori;
do not register it for this bridge.

The initial read-only 2026-10-04 audit found ten correctly routed owned handlers, but
SessionEnd pointed only to the Claude wrapper. Six owned Claude-wrapper entries
also remained under SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop
and SessionEnd. The Claude wrapper cannot infer the provider from stdin and
otherwise creates false Claude roots from Codex activity.

After explicit user authorization, the local `~/.codex/config.toml` was migrated
on the same date: all six misrouted entries were removed/replaced, Codex SessionEnd
was added, and the 11 owned registrations now match the example with the absolute
pinned mimori executable and a five-second timeout. No state-directory override
was added. Parsed before/after comparison verified that unrelated config/hooks
and the entire `[hooks.state]` table, including existing trusted hashes, were
unchanged; the separate `hooks.json` was also unchanged. No trust was auto-approved.

Evidence: [Codex 0.159.2 config schema](https://github.com/openai/codex/blob/ff6aec96948b70d94983af2641a6b67c94faeff5/codex-rs/core/config.schema.json),
[event contracts](https://github.com/openai/codex/blob/ff6aec96948b70d94983af2641a6b67c94faeff5/codex-rs/hooks/src/lib.rs),
and [pinned mimori provider contract](https://github.com/ttak0422/mimori/blob/c5b0d92d511c41be3344a6660778c6ddaa4ab786/docs/providers.md).
`tests/mimori/hooks.py` exercises this fragment with synthetic payloads, including
anonymous permissions and session end. Installed registration is now applied
locally, but no live Codex session was launched. Restart Codex, review the changed
commands through `/hooks` on the next session, and restart Neovim; those activation
steps and live delivery verification remain manual.

Restart Neovim and run `:KomadoToggle`. Historical `komado/codex/*.json` files
are retained and ignored. `KomadoCodexClean` and session-name completion have
been removed. See [integration](../../../docs/mimori.md).
