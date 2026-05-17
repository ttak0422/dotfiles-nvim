#!/usr/bin/env sh
# komado-claude-hook.sh <event_name>
#
# Claude Code hooks から呼ばれ、セッション状態を
# ${XDG_STATE_HOME:-$HOME/.local/state}/komado/claude/<session_id>.json
# に atomic write する。Neovim の komado パネルがこれを読み取って表示する。

set -eu

EVENT="${1:?event name required}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/komado/claude"
mkdir -p "$STATE_DIR"

INPUT="$(cat)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // empty')"
[ -n "$SID" ] || exit 0

CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty')"
NAME="${KOMADO_CLAUDE_SESSION_NAME:-${CWD##*/}}"
TS="$(date -u +%s)"
FILE="$STATE_DIR/$SID.json"
TMP="$FILE.tmp.$$"

if [ "$EVENT" = "SessionEnd" ]; then
  rm -f "$FILE"
  exit 0
fi

case "$EVENT" in
SessionStart)
  STATUS=idle
  EXTRA='{}'
  ;;
UserPromptSubmit)
  PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // ""' | tr '\n\r\t' '   ' | head -c 80)"
  STATUS=running
  EXTRA="$(jq -n --arg p "$PROMPT" '{prompt_summary:$p}')"
  ;;
PreToolUse)
  TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"
  STATUS=waiting
  EXTRA="$(jq -n --arg t "$TOOL" '{last_tool:$t}')"
  ;;
PostToolUse)
  STATUS=running
  EXTRA='{}'
  ;;
Notification)
  MSG="$(printf '%s' "$INPUT" | jq -r '.message // ""')"
  STATUS=waiting
  EXTRA="$(jq -n --arg m "$MSG" '{notification:$m}')"
  ;;
Stop)
  STATUS=done
  EXTRA='{}'
  ;;
*)
  exit 0
  ;;
esac

PREV='{}'
[ -f "$FILE" ] && PREV="$(cat "$FILE")"

printf '%s' "$PREV" | jq \
  --arg sid "$SID" \
  --arg cwd "$CWD" \
  --arg name "$NAME" \
  --arg st "$STATUS" \
  --arg ev "$EVENT" \
  --argjson ts "$TS" \
  --argjson extra "$EXTRA" \
  '. + $extra + {
      session_id: $sid,
      cwd: $cwd,
      name: $name,
      status: $st,
      last_event: $ev,
      last_event_at: $ts,
      started_at: (.started_at // $ts)
   }' >"$TMP"

mv "$TMP" "$FILE"
