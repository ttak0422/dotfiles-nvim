# claude-hooks

A bridge that pipes Claude Code (CLI) session state into the Neovim komado side
panel via the Claude Code hooks mechanism.

## komado-claude-hook.sh

Invoked by each Claude Code hook event. It writes the session state to a JSON
file, which the komado `ClaudeStatus` section reads and renders.

### Behavior

The first argument is the event name. The script parses the JSON from stdin
and transitions the status accordingly.

| event              | status     | extra fields                |
| ------------------ | ---------- | --------------------------- |
| `SessionStart`     | `idle`     | `started_at`                |
| `UserPromptSubmit` | `thinking` | `prompt_summary` (first 80) |
| `PreToolUse`       | `running`  | `last_tool`                 |
| `PostToolUse`      | `idle`     | -                           |
| `Notification`     | `waiting`  | `notification`              |
| `Stop`             | `done`     | -                           |
| `SessionEnd`       | -          | (file removed)              |

Output path: `${XDG_STATE_HOME:-$HOME/.local/state}/komado/claude/<session_id>.json`

Writes are made atomic via tmp + `mv`, so they tolerate concurrent hook
invocations.

### Dependencies

- POSIX sh
- `jq`

This repository's `v2/default.nix` includes `pkgs.jq` in `extraPackages`, so it
is reachable from the Neovim runtime. Since Claude Code launches hooks as a
separate process, `jq` must also be available on the system `PATH`.

### Registering in `~/.claude/settings.json`

Replace `<path>` with the absolute directory where this script lives
(e.g. `~/ghq/github.com/<user>/dotfiles-nvim/v2/scripts/claude-hooks`).
Claude Code's `settings.json` is expected to be edited directly rather than
managed declaratively (home-manager, etc.), because Claude rewrites the file
itself.

```json
{
  "hooks": {
    "SessionStart":     [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh SessionStart" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh UserPromptSubmit" }] }],
    "PreToolUse":       [{ "matcher": "", "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh PreToolUse" }] }],
    "PostToolUse":      [{ "matcher": "", "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh PostToolUse" }] }],
    "Notification":     [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh Notification" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh Stop" }] }],
    "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh SessionEnd" }] }]
  }
}
```

### Verification

1. Add the configuration above to `~/.claude/settings.json`
2. Run `claude` in any directory
3. Open Neovim in the same cwd and call `:KomadoToggle`
4. A row appears under the `Claude (N)` section
5. Send a prompt or `/exit` and confirm the display reacts

### State file shape

```json
{
  "session_id": "abc123",
  "cwd": "/Users/tak/proj/foo",
  "status": "running",
  "started_at": 1715900000,
  "last_event": "PreToolUse",
  "last_event_at": 1715900123,
  "last_tool": "Bash",
  "prompt_summary": "..."
}
```

### Disabling

- Remove the relevant hook entries from `~/.claude/settings.json`
- Optionally run `:KomadoClaudeClean` inside Neovim to wipe the state files
- Removing the `${XDG_STATE_HOME:-$HOME/.local/state}/komado/claude/`
  directory itself causes the `ClaudeStatus` section to vanish on the next
  Neovim reload (Neovim gates the section on directory existence)

### Notes

- If a Claude Code process dies abnormally `SessionEnd` is never fired and the
  state file lingers. Neovim marks any session whose last event is older than
  30 minutes as stale, and removes files older than 24 hours at startup.
- Sessions whose `cwd` does not match are not shown in komado (filtering
  happens on the Neovim side).
