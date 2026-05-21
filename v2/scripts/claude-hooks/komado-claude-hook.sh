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

PREV='{}'
[ -f "$FILE" ] && PREV="$(cat "$FILE")"
CUR="$(printf '%s' "$PREV" | jq -r '.status // empty')"

EXTRA='{}'
case "$EVENT" in
SessionStart)
  STATUS=idle
  ;;
UserPromptSubmit)
  # 新しい操作の開始。stopped でも running に戻す。
  PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // ""' | tr '\n\r\t' '   ' | head -c 80)"
  STATUS=running
  EXTRA="$(jq -n --arg p "$PROMPT" '{prompt_summary:$p}')"
  ;;
Stop)
  STATUS=stopped
  ;;
PreToolUse)
  TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"
  EXTRA="$(jq -n --arg t "$TOOL" '{last_tool:$t}')"
  if [ "$CUR" = "stopped" ]; then STATUS=stopped; else STATUS=running; fi
  ;;
PostToolUse)
  if [ "$CUR" = "stopped" ]; then STATUS=stopped; else STATUS=running; fi
  ;;
Notification)
  MSG="$(printf '%s' "$INPUT" | jq -r '.message // ""')"
  NTYPE="$(printf '%s' "$INPUT" | jq -r '.notification_type // ""')"
  EXTRA="$(jq -n --arg m "$MSG" '{notification:$m}')"
  # permission_prompt は入力待ち。notification_type を送らない Claude Code
  # 環境では取りこぼさないよう空文字もフォールバックで waiting_input にする。
  if [ "$NTYPE" = "permission_prompt" ] || [ -z "$NTYPE" ]; then
    STATUS=waiting_input
  elif [ "$CUR" = "stopped" ]; then
    STATUS=stopped
  else
    STATUS=running
  fi
  ;;
*)
  exit 0
  ;;
esac

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
