#!/usr/bin/env bash

# Check if a command exists
check() {
  command -v "$1" >/dev/null 2>&1
}

# Send a desktop notification (or fallback to echo)
notify() {
  if check notify-send; then
    notify-send -a "wlsunset" "$@"
  else
    echo "$@"
  fi
}

# Show current status as JSON for Waybar
show_status() {
  if pgrep -x wlsunset >/dev/null; then
    echo '{"text": "󰖙", "tooltip": "wlsunset is active\nWarm light filter enabled"}'
  else
    echo '{"text": "󰖚", "tooltip": "wlsunset is inactive\nNormal color temperature"}'
  fi
}

# Toggle wlsunset on/off
toggle_wlsunset() {
  if pgrep -x wlsunset >/dev/null; then
    pkill -x wlsunset
    notify "wlsunset stopped"
  else
    wlsunset -t 3000 -T 6500 -l auto -L auto & disown
    notify "wlsunset started (warm filter applied)"
  fi

  # Trigger Waybar to refresh the module
  pkill -RTMIN+11 waybar 2>/dev/null
}

# ----- Main logic -----

# Exit early if wlsunset is not installed
if ! check wlsunset; then
  notify "wlsunset not found"
  echo '{"text": "󰖚", "tooltip": "wlsunset not installed"}'
  exit 1
fi

# If the script is called with "status", only show status
if [[ "$1" == "status" ]]; then
  show_status
  exit 0
fi

# Otherwise, toggle wlsunset
toggle_wlsunset
