#!/usr/bin/env bash
# Signal CLI daemon with receive → save → notify
# Runs: signal-cli daemon --http=127.0.0.1:8080, subscribes to /api/v1/events (SSE)
# Usage: signal-daemon.sh [--receive-only]  (receive-only = signal-cli receive loop, no daemon)

set -euo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/signal-sync/config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config not found. Copy packages/signal-sync/config to ~/.config/signal-sync/config"
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

SIGNAL_CLI="${SIGNAL_CLI:-signal-cli}"
SIGNAL_HTTP="${SIGNAL_HTTP:-http://127.0.0.1:8080}"
MESSAGES_FILE="${SIGNAL_DATA_DIR}/messages.log"
mkdir -p "$SIGNAL_DATA_DIR"

# Process and save a message (from plain-text buffer or JSON)
process_message() {
  local sender="$1" body="$2"
  [[ -z "$body" ]] && return

  echo "[$(date -Iseconds)] From: $sender | $body" >>"$MESSAGES_FILE"

  local preview="${body:0:150}"
  [[ ${#body} -gt 150 ]] && preview="${preview}..."

  notify-send -a "${SIGNAL_APP_NAME:-signal-sync}" -u normal "Signal: $sender" "$preview"
}

# Parse plain-text daemon output (Envelope from:, Body:, etc.)
process_daemon_output() {
  local buffer="$1"
  local sender body

  sender=$(echo "$buffer" | grep "Envelope from:" | sed -E 's/Envelope from: *"?([^"]+)"?.*/\1/' | tr -d ' ')
  [[ -z "$sender" ]] && return

  body=$(echo "$buffer" | awk '
    /Body:/{found=1; sub(/.*Body: ?/,""); if($0) print; next}
    found && /(Attachments:|Group info:|With profile key)/{found=0; next}
    found{print}
  ')
  body=$(echo "$body" | paste -sd ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [[ -z "$body" ]] && return

  process_message "$sender" "$body"
}

# Parse SSE event JSON (from /api/v1/events)
# Format: {"account":"+...","envelope":{"source":"...","dataMessage":{"message":"..."}}}
# Or sync: envelope.syncMessage.sentMessage.message
process_sse_event() {
  local json="$1"
  [[ -z "$json" ]] && return

  if ! command -v jq &>/dev/null; then return; fi

  local sender body
  # SSE format: .envelope at top level; JSON-RPC would have .params.envelope
  sender=$(echo "$json" | jq -r '.envelope.source // .envelope.sourceNumber // .params.envelope.source // .params.envelope.sourceNumber // .account // "unknown"')
  body=$(echo "$json" | jq -r '.envelope.dataMessage.message // .envelope.syncMessage.sentMessage.message // .params.envelope.dataMessage.message // .params.envelope.syncMessage.sentMessage.message // ""')
  [[ -n "$body" ]] && process_message "$sender" "$body"
}

# Receive-only mode: signal-cli receive loop (no daemon)
receive_loop() {
  while true; do
    "$SIGNAL_CLI" -u "$SIGNAL_NUMBER" receive --timeout 30 2>/dev/null | {
      buffer=""
      while IFS= read -r line || true; do
        [[ -z "$line" ]] && continue
        if [[ "$line" == *"Envelope from:"* ]]; then
          [[ -n "$buffer" ]] && process_daemon_output "$buffer"
          buffer="$line"
        elif [[ -n "$buffer" ]]; then
          buffer="$buffer"$'\n'"$line"
          [[ "$line" == *"Attachments:"* || "$line" == *"Group info:"* || "$line" == *"With profile key"* ]] && {
            process_daemon_output "$buffer"
            buffer=""
          }
        fi
      done
      [[ -n "$buffer" ]] && process_daemon_output "$buffer"
    }
    sleep 2
  done
}

# Wait for HTTP server to be ready
wait_for_http() {
  local max=30 i=0
  while [[ $i -lt $max ]]; do
    if curl -s -o /dev/null -w '%{http_code}' --connect-timeout 2 "${SIGNAL_HTTP}/api/v1/check" 2>/dev/null | grep -q 200; then
      return 0
    fi
    sleep 1
    ((i++)) || true
  done
  echo "Error: HTTP server not ready after ${max}s"
  return 1
}

# Run daemon + subscribe to SSE events (reliable under systemd)
run_daemon() {
  local daemon_args=()
  [[ -n "${SIGNAL_DAEMON_ARGS:-}" ]] && read -ra daemon_args <<<"$SIGNAL_DAEMON_ARGS"

  # Start daemon in background
  "$SIGNAL_CLI" -u "$SIGNAL_NUMBER" daemon "${daemon_args[@]}" &
  local daemon_pid=$!

  cleanup() {
    kill "$daemon_pid" 2>/dev/null || true
    exit 0
  }
  trap cleanup TERM INT

  # Wait for HTTP, then subscribe to SSE events
  if ! wait_for_http; then
    kill "$daemon_pid" 2>/dev/null || true
    exit 1
  fi

  # Subscribe to events and parse SSE stream (data: {...})
  curl -s -N --connect-timeout 10 "${SIGNAL_HTTP}/api/v1/events" 2>/dev/null | while IFS= read -r line || true; do
    [[ "$line" == data:* ]] || continue
    process_sse_event "${line#data:}"
  done

  kill "$daemon_pid" 2>/dev/null || true
}

if [[ "${1:-}" == "--receive-only" ]]; then
  receive_loop
else
  run_daemon
fi
