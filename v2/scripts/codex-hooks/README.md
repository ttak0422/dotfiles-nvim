# codex-hooks

A bridge that pipes Codex CLI session state into the Neovim komado side panel
via the Codex lifecycle hooks mechanism.

## komado-codex-hook.sh

Invoked by each Codex hook event. It writes the session state to a JSON file,
which the komado `CodexStatus` section reads and renders.

### Behavior

The script parses the JSON hook payload from stdin and transitions the status
accordingly. Once a session becomes `stopped` it stays `stopped` until the next
`UserPromptSubmit`.

| event              | status                              | extra fields                |
| ------------------ | ----------------------------------- | --------------------------- |
| `SessionStart`     | `waiting_input`                     | `source`, `started_at`      |
| `UserPromptSubmit` | `running` (resumes from `stopped`)  | `prompt_summary` (first 80) |
| `PermissionRequest`| `waiting_input`                     | `last_tool`, `waiting_reason` |
| `PreToolUse`       | `running` (kept `stopped` if so)    | `last_tool`                 |
| `PostToolUse`      | `running` (kept `stopped` if so)    | -                           |
| `PreCompact`       | `running` (kept `stopped` if so)    | `last_tool`, `compact_trigger` |
| `PostCompact`      | `running` (kept `stopped` if so)    | -                           |
| `SubagentStart`    | `running` (kept `stopped` if so)    | `last_tool`, `agent_*`      |
| `SubagentStop`     | `running` (kept `stopped` if so)    | `last_message`              |
| `Stop`             | `stopped`                           | `last_message`              |

Output path: `${XDG_STATE_HOME:-$HOME/.local/state}/komado/codex/<session_id>.json`

Writes are made atomic via tmp + `mv`, so they tolerate concurrent hook
invocations.

### Dependencies

- POSIX sh
- `jq`

This repository's `v2/default.nix` includes `pkgs.jq` in `extraPackages`, so it
is reachable from the Neovim runtime. Since Codex launches hooks as a separate
process, `jq` must also be available on the system `PATH`.

### Registering in `~/.codex/config.toml`

Replace `<path>` with the absolute directory where this script lives
(e.g. `~/ghq/github.com/<user>/dotfiles-nvim/v2/scripts/codex-hooks`).

```toml
[[hooks.SessionStart]]
matcher = "startup|resume|clear|compact"
[[hooks.SessionStart.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.UserPromptSubmit]]
[[hooks.UserPromptSubmit.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.PermissionRequest]]
matcher = "*"
[[hooks.PermissionRequest.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.PreToolUse]]
matcher = "*"
[[hooks.PreToolUse.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.PostToolUse]]
matcher = "*"
[[hooks.PostToolUse.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.PreCompact]]
matcher = "manual|auto"
[[hooks.PreCompact.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.PostCompact]]
matcher = "manual|auto"
[[hooks.PostCompact.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.SubagentStart]]
matcher = "*"
[[hooks.SubagentStart.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.SubagentStop]]
matcher = "*"
[[hooks.SubagentStop.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"

[[hooks.Stop]]
[[hooks.Stop.hooks]]
type = "command"
command = "<path>/komado-codex-hook.sh"
```

After editing the config, start Codex and run `/hooks` to review and trust the
hook definitions. Codex skips non-managed command hooks until they are trusted.

### Verification

1. Add the configuration above to `~/.codex/config.toml`
2. Run `codex` in any directory and execute `/hooks`
3. Trust the `komado-codex-hook.sh` entries
4. Open Neovim and call `:KomadoToggle`
5. Send a prompt or let a turn stop and confirm the display reacts

### State file shape

```json
{
  "session_id": "abc123",
  "cwd": "/Users/tak/proj/foo",
  "name": "foo",
  "model": "gpt-5.5",
  "status": "running",
  "started_at": 1715900000,
  "last_event": "PreToolUse",
  "last_event_at": 1715900123,
  "last_tool": "Bash",
  "prompt_summary": "...",
  "last_message": "..."
}
```

### Disabling

- Remove the relevant hook entries from `~/.codex/config.toml`
- Optionally run `:KomadoCodexClean` inside Neovim to wipe the state files
- Removing the `${XDG_STATE_HOME:-$HOME/.local/state}/komado/codex/`
  directory itself causes the `CodexStatus` section to vanish on the next
  Neovim reload
