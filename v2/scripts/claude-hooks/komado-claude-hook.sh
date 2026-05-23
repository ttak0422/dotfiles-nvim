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

# stdin JSON から jq フィルタで1値を取り出す
input_field() {
  printf '%s' "$INPUT" | jq -r "$1"
}

# stopped は維持、それ以外は running を返す($CUR を参照)
running_unless_stopped() {
  if [ "$CUR" = "stopped" ]; then printf stopped; else printf running; fi
}

SID="$(input_field '.session_id // empty')"
[ -n "$SID" ] || exit 0

# KOMADO_CLAUDE_DEBUG が設定されていれば全イベントを記録する(permission 検証用)。
if [ -n "${KOMADO_CLAUDE_DEBUG:-}" ]; then
  printf '%s\t%s\tntype=%s\tmsg=%s\n' \
    "$(date -u +%H:%M:%S)" "$EVENT" \
    "$(input_field '.notification_type // ""')" \
    "$(input_field '.message // ""')" >>"$STATE_DIR/debug.log"
fi

CWD="$(input_field '.cwd // empty')"

# Claude のセッション名(/rename で更新される)を sessionId 一致で引く。
# hook の stdin には含まれないため ~/.claude/sessions/<pid>.json を走査する。
SESSIONS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/sessions"
SESSION_NAME=""
if [ -d "$SESSIONS_DIR" ]; then
  SESSION_NAME="$(jq -r --arg sid "$SID" 'select(.sessionId == $sid) | .name // empty' "$SESSIONS_DIR"/*.json 2>/dev/null | head -n1)"
fi

# 優先順: 明示 override > Claude セッション名(/rename) > cwd ベース名
NAME="${KOMADO_CLAUDE_SESSION_NAME:-${SESSION_NAME:-${CWD##*/}}}"
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

# transcript の末尾 assistant メッセージ(最初の text ブロック)を取り出す。
# 取れない場合は空文字のまま。空なら下流で既存値を維持する。
TRANSCRIPT="$(input_field '.transcript_path // empty')"
LAST_MSG=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  LAST_MSG="$(jq -rs '
    [ .[]
      | select(type == "object" and .type == "assistant")
      | (.message.content // [])
      | if type == "array" then . else [] end
      | map(select(.type == "text" and (.text // "") != "") | .text)
      | .[0]
      | select(. != null)
    ] | last // empty
  ' "$TRANSCRIPT" 2>/dev/null | tr '\n\r\t' '   ' | head -c 120)"
fi

EXTRA='{}'
case "$EVENT" in
SessionStart)
  # 起動直後はユーザー入力待ち。idle は廃止し waiting_input に統合した。
  STATUS=waiting_input
  ;;
UserPromptSubmit)
  # 新しい操作の開始。stopped でも running に戻す。
  PROMPT="$(input_field '.prompt // ""' | tr '\n\r\t' '   ' | head -c 80)"
  STATUS=running
  EXTRA="$(jq -n --arg p "$PROMPT" '{prompt_summary:$p}')"
  ;;
Stop)
  STATUS=stopped
  ;;
PreToolUse)
  TOOL="$(input_field '.tool_name // ""')"
  EXTRA="$(jq -n --arg t "$TOOL" '{last_tool:$t}')"
  STATUS="$(running_unless_stopped)"
  ;;
PostToolUse)
  STATUS="$(running_unless_stopped)"
  ;;
Notification)
  MSG="$(input_field '.message // ""')"
  NTYPE="$(input_field '.notification_type // ""')"
  EXTRA="$(jq -n --arg m "$MSG" '{notification:$m}')"
  # ユーザー入力待ちになる通知を waiting_input にする:
  #   permission_prompt   : ツール実行の許可待ち
  #   elicitation_dialog  : MCP ツールが入力を要求
  #   ""(空)             : notification_type を送らない環境のフォールバック
  # idle_prompt(完了後の放置)/ auth_success(情報通知)は待ち扱いにせず、
  # running_unless_stopped に委ねる(完了後は stopped が維持される)。
  case "$NTYPE" in
  permission_prompt | elicitation_dialog | "")
    STATUS=waiting_input
    ;;
  *)
    STATUS="$(running_unless_stopped)"
    ;;
  esac
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
  --arg msg "$LAST_MSG" \
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
   }
   | if $msg != "" then .last_message = $msg else . end' >"$TMP"

mv "$TMP" "$FILE"
