#!/usr/bin/env bash
# View saved Signal messages
# Usage: signal-view.sh [N]  (show last N lines, default 50)

set -euo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/signal-sync/config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config not found."
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

MESSAGES_FILE="${SIGNAL_DATA_DIR}/messages.log"
lines="${1:-50}"

[[ ! -f "$MESSAGES_FILE" ]] && { echo "No messages yet."; exit 0; }

tail -n "$lines" "$MESSAGES_FILE" | less -R
