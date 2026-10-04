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

Registration is a separate manual activation step: replace only the old owned
hook commands after reviewing mimori's supported events, preserve unrelated
hooks, and use the provider's normal review flow. No installed
`~/.codex/config.toml` is modified by this branch. Existing registrations pointing
at the primary checkout change behavior only after this branch is adopted there.

Restart Neovim and run `:KomadoToggle`. Historical `komado/codex/*.json` files
are retained and ignored. `KomadoCodexClean` and session-name completion have
been removed. See [integration](../../../docs/mimori.md).
