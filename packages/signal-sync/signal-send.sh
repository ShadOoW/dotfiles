#!/usr/bin/env bash
# Send a message to self via Signal CLI daemon HTTP API
# Usage: signal-send.sh "message"  OR  echo "message" | signal-send.sh
# Requires: signal-cli daemon running with --http=127.0.0.1:8080

set -euo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/signal-sync/config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config not found. Copy packages/signal-sync/config to ~/.config/signal-sync/config"
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

# Get message from arg or stdin
if [[ -n "${1:-}" ]]; then
  msg="$*"
else
  msg=$(cat)
fi

[[ -z "$msg" ]] && { echo "Usage: signal-send.sh <message>"; exit 1; }

# Use daemon HTTP API (avoids "config in use" when daemon is running)
SIGNAL_HTTP="${SIGNAL_HTTP:-http://127.0.0.1:8080}"

if command -v jq &>/dev/null; then
  json=$(jq -n --arg msg "$msg" --arg recipient "$SIGNAL_NUMBER" \
    '{jsonrpc:"2.0",method:"send",params:{recipient:[$recipient],message:$msg},id:1}')
else
  # Fallback: escape quotes in message for JSON
  escaped_msg=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g')
  json="{\"jsonrpc\":\"2.0\",\"method\":\"send\",\"params\":{\"recipient\":[\"$SIGNAL_NUMBER\"],\"message\":\"$escaped_msg\"},\"id\":1}"
fi

response=$(curl -s -X POST "${SIGNAL_HTTP}/api/v1/rpc" \
  -H "Content-Type: application/json" \
  -d "$json")

if echo "$response" | grep -q '"error"'; then
  echo "Error: $(echo "$response" | grep -o '"message":"[^"]*"' | head -1)"
  exit 1
fi
