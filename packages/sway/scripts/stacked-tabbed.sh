#!/bin/bash

# Get parent container layout of the focused window
CURRENT_LAYOUT=$(swaymsg -t get_tree | jq -r '.. | select(.nodes? // [] | .[] | .focused? == true) | .layout')

# Toggle layout
if [ "$CURRENT_LAYOUT" = "tabbed" ]; then
    swaymsg layout stacking
else
    swaymsg layout tabbed
fi
