#!/usr/bin/env sh
# komado-codex-hook.sh
#
# Codex CLI hooks から呼ばれ、セッション状態を
# ${XDG_STATE_HOME:-$HOME/.local/state}/komado/codex/<session_id>.json
# に atomic write する。Neovim の komado パネルがこれを読み取って表示する。

set -eu

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/komado/codex"
mkdir -p "$STATE_DIR"

INPUT="$(cat)"

input_field() {
  printf '%s' "$INPUT" | jq -r "$1"
}

one_line_field() {
  printf '%s' "$(input_field "$1")" | tr '\n\r\t' '   ' | head -c "$2"
}

running_unless_stopped() {
  if [ "$CUR" = "stopped" ]; then printf stopped; else printf running; fi
}

SID="$(input_field '.session_id // empty')"
[ -n "$SID" ] || exit 0

EVENT="$(input_field '.hook_event_name // empty')"
[ -n "$EVENT" ] || exit 0

if [ -n "${KOMADO_CODEX_DEBUG:-}" ]; then
  printf '%s\t%s\ttool=%s\tmodel=%s\n' \
    "$(date -u +%H:%M:%S)" "$EVENT" \
    "$(input_field '.tool_name // ""')" \
    "$(input_field '.model // ""')" >>"$STATE_DIR/debug.log"
fi

CWD="$(input_field '.cwd // empty')"
NAME="${KOMADO_CODEX_SESSION_NAME:-${CWD##*/}}"
MODEL="$(input_field '.model // empty')"
PERMISSION_MODE="$(input_field '.permission_mode // empty')"
TURN_ID="$(input_field '.turn_id // empty')"
TS="$(date -u +%s)"
FILE="$STATE_DIR/$SID.json"
TMP="$FILE.tmp.$$"

PREV='{}'
[ -f "$FILE" ] && PREV="$(cat "$FILE")"
CUR="$(printf '%s' "$PREV" | jq -r '.status // empty')"

LAST_MSG="$(one_line_field '.last_assistant_message // ""' 120)"

EXTRA='{}'
case "$EVENT" in
SessionStart)
  STATUS=waiting_input
  SOURCE="$(input_field '.source // ""')"
  EXTRA="$(jq -n --arg source "$SOURCE" '{source:$source}')"
  ;;
UserPromptSubmit)
  PROMPT="$(one_line_field '.prompt // ""' 80)"
  STATUS=running
  EXTRA="$(jq -n --arg p "$PROMPT" '{prompt_summary:$p}')"
  ;;
PermissionRequest)
  TOOL="$(input_field '.tool_name // ""')"
  EXTRA="$(jq -n --arg t "$TOOL" '{last_tool:$t, waiting_reason:"permission"}')"
  STATUS=waiting_input
  ;;
PreToolUse)
  TOOL="$(input_field '.tool_name // ""')"
  EXTRA="$(jq -n --arg t "$TOOL" '{last_tool:$t}')"
  STATUS="$(running_unless_stopped)"
  ;;
PostToolUse)
  STATUS="$(running_unless_stopped)"
  ;;
PreCompact)
  TRIGGER="$(input_field '.trigger // ""')"
  EXTRA="$(jq -n --arg trigger "$TRIGGER" '{last_tool:"compact", compact_trigger:$trigger}')"
  STATUS="$(running_unless_stopped)"
  ;;
PostCompact)
  STATUS="$(running_unless_stopped)"
  ;;
SubagentStart)
  AGENT_TYPE="$(input_field '.agent_type // ""')"
  AGENT_ID="$(input_field '.agent_id // ""')"
  EXTRA="$(jq -n --arg typ "$AGENT_TYPE" --arg id "$AGENT_ID" '{last_tool:("subagent:" + $typ), agent_id:$id, agent_type:$typ}')"
  STATUS="$(running_unless_stopped)"
  ;;
SubagentStop)
  LAST_MSG="$(one_line_field '.last_assistant_message // ""' 120)"
  STATUS="$(running_unless_stopped)"
  ;;
Stop)
  STATUS=stopped
  ;;
*)
  exit 0
  ;;
esac

printf '%s' "$PREV" | jq \
  --arg sid "$SID" \
  --arg cwd "$CWD" \
  --arg name "$NAME" \
  --arg model "$MODEL" \
  --arg permission_mode "$PERMISSION_MODE" \
  --arg turn_id "$TURN_ID" \
  --arg st "$STATUS" \
  --arg ev "$EVENT" \
  --arg msg "$LAST_MSG" \
  --argjson ts "$TS" \
  --argjson extra "$EXTRA" \
  '. + $extra + {
      session_id: $sid,
      cwd: $cwd,
      name: $name,
      model: $model,
      permission_mode: $permission_mode,
      status: $st,
      last_event: $ev,
      last_event_at: $ts,
      started_at: (.started_at // $ts)
   }
   | if $turn_id != "" then .turn_id = $turn_id else . end
   | if $msg != "" then .last_message = $msg else . end' >"$TMP"

mv "$TMP" "$FILE"
