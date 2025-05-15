#!/bin/bash

# Get the command the user wants to run
if [ $# -gt 0 ]; then
    requested_cmd="$*"
else
    requested_cmd="rofi -show run"
fi

# Get the full line of the running Rofi command (excluding this script)
rofi_proc=$(ps aux | grep '[r]ofi' | grep -v "$0")

if [ -n "$rofi_proc" ]; then
    # Check if current Rofi command includes -display-columns (assume it's cliphist)
    if echo "$rofi_proc" | grep -q "\-display-columns"; then
        # Current mode is cliphist
        if echo "$requested_cmd" | grep -q "\-display-columns"; then
            # Requested cliphist again → toggle
            pkill -x rofi
        else
            # Switching from cliphist to drun
            pkill -x rofi
            sleep 0.1
            eval "$requested_cmd" &
        fi
    else
        # Current mode is not cliphist (assume drun or others)
        if echo "$requested_cmd" | grep -q "\-display-columns"; then
            # Switching from drun to cliphist
            pkill -x rofi
            sleep 0.1
            eval "$requested_cmd" &
        else
            # Requested drun again → toggle
            pkill -x rofi
        fi
    fi
else
    # No Rofi running, launch the requested command
    eval "$requested_cmd" &
fi
