#!/bin/bash

# Get the command the user wants to run
if [ $# -gt 0 ]; then
  requested_cmd="$*"
else
  requested_cmd="rofi -show run"
fi

# Check if rofi is running using pgrep (more reliable than ps grep)
if pgrep -x rofi >/dev/null 2>&1; then
  # Rofi is running - kill it
  pkill -x rofi
else
  # Rofi not running, launch the requested command
  eval "$requested_cmd" &
fi
exit 0
