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

## Registration (Claude Code 2.1.281 / mimori c5b0d92)

Use [settings.example.json](settings.example.json) as the **owned hook fragment**
for `~/.claude/settings.json`, not as a replacement settings file. Replace
`/absolute/path/to/mimori` with the pinned executable and
`/absolute/path/to/dotfiles-nvim` with this checkout. Each command explicitly sets
`MIMORI_BIN`: the Neovim client's Nix binary path does not configure provider
processes. The example uses a five-second outer timeout and no event argument.
If you override the client's state directory, also set `MIMORI_STATE_DIR` in these
commands (or the provider environment) to that same absolute private directory.

Merge one owned handler per event, replacing any old Komado handler rather than
adding a duplicate. Preserve unrelated handlers in the same event arrays and all
other settings. The tracked fragment does not automatically edit installed settings.

The example covers SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest,
PostToolUse, PostToolUseFailure, PreCompact, PostCompact, SubagentStart,
SubagentStop, Elicitation, ElicitationResult, Notification, Stop and SessionEnd.
Notification **must** use `permission_prompt|elicitation_dialog`; informational
types such as `idle_prompt`, `auth_success` and `elicitation_url_dialog` are
rejected by this pinned mimori. PermissionRequest observes a prompt immediately;
Notification is a delayed fallback, not a substitute for it. Elicitation and
ElicitationResult can correlate requests when server/elicitation IDs are present.

The initial read-only 2026-10-04 audit found owned handlers for only SessionStart,
UserPromptSubmit, PreToolUse, PostToolUse, Notification, Stop and SessionEnd, with
no Notification matcher. After explicit user authorization, the local
`~/.claude/settings.json` was migrated on the same date: eight owned handlers were
added, the owned Notification matcher was narrowed, and all 15 owned commands now
use the absolute pinned mimori executable, the Claude wrapper and a five-second
timeout. No state-directory override was added. Parsed before/after comparison
verified that unrelated settings and handlers were preserved.

Evidence: [Claude hook reference](https://code.claude.com/docs/en/hooks) and
[pinned mimori provider contract](https://github.com/ttak0422/mimori/blob/c5b0d92d511c41be3344a6660778c6ddaa4ab786/docs/providers.md).
The example is exercised with synthetic payloads by `tests/mimori/hooks.py`;
installed registration is now applied locally, but live provider delivery has not
been tested. Restart/reload Claude Code and restart Neovim to complete activation.

Start Neovim with the new configuration, then `:KomadoToggle` to ensure the
shared collector on demand. Existing historical `komado/claude/*.json` files are
ignored and retained. `KomadoClaudeClean` and the process reaper are removed.
See [integration](../../../docs/mimori.md) for validation and client settings.
