#!/bin/sh
# Tracked replacement for the former JSON/transcript bridge. The optional old
# event argument is ignored: the provider payload owns hook_event_name.
set -eu
set -- hook --provider claude --generation "${MIMORI_GENERATION:-1}"
if [ -n "${MIMORI_STATE_DIR:-}" ]; then set -- "$@" --state-dir "$MIMORI_STATE_DIR"; fi
exec "${MIMORI_BIN:-mimori}" "$@"
