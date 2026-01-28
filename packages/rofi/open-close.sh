#!/bin/bash

# Get the command the user wants to run
if [ $# -gt 0 ]; then
    requested_cmd="$*"
else
    requested_cmd="rofi -show run"
fi

# Get the full command line of the running Rofi process (excluding this script)
rofi_proc=$(ps aux | grep '[r]ofi' | grep -v "$0" | head -1)

if [ -n "$rofi_proc" ]; then
    # Extract the command portion after the process info
    current_cmd=$(echo "$rofi_proc" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/[[:space:]]*$//')

    # Normalize commands for comparison by removing variable parts
    normalize_cmd() {
        local cmd="$1"
        # Remove path prefixes and normalize
        cmd=$(echo "$cmd" | sed 's|.*rofi/open-close\.sh ||g')
        cmd=$(echo "$cmd" | sed 's|bash.*custom-commands\.sh|custom-commands|g')
        cmd=$(echo "$cmd" | sed 's|.*custom-commands\.sh|custom-commands|g')
        cmd=$(echo "$cmd" | sed 's|cliphist.*wl-copy|clipboard|g')
        cmd=$(echo "$cmd" | sed 's|.*rofi -dmenu -display-columns.*|clipboard|g')
        cmd=$(echo "$cmd" | sed 's|rofi -show run|run|g')
        cmd=$(echo "$cmd" | sed 's|rofi -show window|window|g')
        echo "$cmd" | xargs  # trim whitespace
    }

    current_normalized=$(normalize_cmd "$current_cmd")
    requested_normalized=$(normalize_cmd "$requested_cmd")

    # If the same command is requested, toggle (close)
    if [ "$current_normalized" = "$requested_normalized" ]; then
        pkill -x rofi
        exit 0
    else
        # Different command requested, kill current and start new
        pkill -x rofi
        sleep 0.1
        eval "$requested_cmd" &
        exit 0
    fi
else
    # No Rofi running, launch the requested command
    eval "$requested_cmd" &
    exit 0
fi
