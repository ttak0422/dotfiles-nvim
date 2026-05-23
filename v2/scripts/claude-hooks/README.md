# claude-hooks

A bridge that pipes Claude Code (CLI) session state into the Neovim komado side
panel via the Claude Code hooks mechanism.

## komado-claude-hook.sh

Invoked by each Claude Code hook event. It writes the session state to a JSON
file, which the komado `ClaudeStatus` section reads and renders.

### Behavior

The first argument is the event name. The script parses the JSON from stdin
and transitions the status accordingly. Once a session becomes `stopped` it
stays `stopped` until the next `UserPromptSubmit`.

| event              | status                                                 | extra fields                |
| ------------------ | ------------------------------------------------------ | --------------------------- |
| `SessionStart`     | `waiting_input`                                        | `started_at`                |
| `UserPromptSubmit` | `running` (resumes from `stopped`)                     | `prompt_summary` (first 80) |
| `PreToolUse`       | `running` (kept `stopped` if already so)               | `last_tool`                 |
| `PostToolUse`      | `running` (kept `stopped` if already so)               | -                           |
| `Notification`     | `waiting_input` for input-waiting types, else `running`| `notification`              |
| `Stop`             | `stopped`                                              | -                           |
| `SessionEnd`       | -                                                      | (file removed)              |

> The status set is `running` / `waiting_input` / `stopped` (modeled on
> claude-code-monitor). A freshly started session is `waiting_input` until the
> first prompt arrives.
>
> Whenever `transcript_path` is available the script extracts the latest
> assistant text message from the transcript and stores it as `last_message`
> (first 120 chars). komado shows this as the per-session summary line, falling
> back to `prompt_summary` when no assistant message exists yet. An empty
> extraction keeps the previous `last_message` rather than blanking it.
>
> Input-waiting states are detected via the `notification_type` field. Both
> `permission_prompt` (tool approval) and `elicitation_dialog` (MCP tool asking
> for input) map to `waiting_input`. `idle_prompt` (idle after completion) and
> `auth_success` (informational) do not — they fall through to
> `running_unless_stopped`, so a finished session stays `stopped`. When Claude
> Code does not send the field, an empty value also falls back to
> `waiting_input` so prompts are not missed.

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
    "PreToolUse":       [{ "matcher": "*", "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh PreToolUse" }] }],
    "PostToolUse":      [{ "matcher": "*", "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh PostToolUse" }] }],
    "Notification":     [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh Notification" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh Stop" }] }],
    "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "<path>/komado-claude-hook.sh SessionEnd" }] }]
  }
}
```

### Verification

1. Add the configuration above to `~/.claude/settings.json`
2. Run `claude` in any directory and execute `/hooks` — every event listed
   above must show the `komado-claude-hook.sh` entry. If an event reports
   "No hooks configured", the JSON structure is wrong (most often the
   top-level `"hooks"` wrapper is missing).
3. Open Neovim in the same cwd and call `:KomadoToggle`
4. A row appears under the `Claude (N)` section
5. Send a prompt or `/exit` and confirm the display reacts

### State file shape

```json
{
  "session_id": "abc123",
  "cwd": "/Users/tak/proj/foo",
  "status": "waiting_input",
  "started_at": 1715900000,
  "last_event": "PreToolUse",
  "last_event_at": 1715900123,
  "last_tool": "Bash",
  "prompt_summary": "...",
  "last_message": "..."
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
  state file lingers. There is no automatic staleness handling; run
  `:KomadoClaudeClean` in Neovim to wipe leftover state files.
- Sessions whose `cwd` does not match are not shown in komado (filtering
  happens on the Neovim side).
