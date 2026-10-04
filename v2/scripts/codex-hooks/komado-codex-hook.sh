#!/bin/sh
# Durable bounded ingest only; starting a collector belongs to view demand.
set -eu
set -- hook --provider codex --generation "${MIMORI_GENERATION:-1}"
if [ -n "${MIMORI_STATE_DIR:-}" ]; then set -- "$@" --state-dir "$MIMORI_STATE_DIR"; fi
exec "${MIMORI_BIN:-mimori}" "$@"
