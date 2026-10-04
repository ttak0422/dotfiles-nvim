# Claude hook bridge

`komado-claude-hook.sh` now forwards stdin to `mimori hook --provider claude`.
It does not inspect transcripts, write legacy JSON, launch a daemon, or print a
hook decision. The old optional event argument is ignored; the payload's
`hook_event_name` is authoritative. Mimori bounds input, durable enqueue, and
runtime (two-second watchdog); configure an outer provider timeout as well.

Install `mimori` on the hook process PATH or set `MIMORI_BIN` to its absolute
path. Optional `MIMORI_STATE_DIR` selects the same absolute private state directory
as the Neovim client. `MIMORI_GENERATION` defaults to 1; increase it only for a
verified new incarnation. Raw hooks provide best-effort ordering and permission
counts can remain unknown.

Registration is a separate manual activation step. Replace only the old owned
hook commands in your Claude settings with this tracked wrapper after reviewing
mimori's supported provider events. Preserve unrelated hooks. This change does
not edit installed `~/.claude/settings.json`. Existing registrations pointing
at the primary checkout change behavior only after this branch is adopted there.

Start Neovim with the new configuration, then `:KomadoToggle` to ensure the
shared collector on demand. Existing historical `komado/claude/*.json` files are
ignored and retained. `KomadoClaudeClean` and the process reaper are removed.
See [integration](../../../docs/mimori.md) for validation and client settings.
