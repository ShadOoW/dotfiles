#!/bin/bash

# Usage: toggle-scratchpad.sh [mark_name] [app_id_type] [app_id] [command]
#
# mark_name:   Name for the mark (e.g., terminal, music, explorer)
# app_id_type: Type of selector to use (app_id, class, or instance)
# app_id:      Value of the selector (e.g., terminal-mark, music-mark, explorer-mark)
# command:     Command to launch the application

# Set default values
MARK_NAME=${1:-"unknown"}
APP_ID_TYPE=${2:-"app_id"}
APP_ID=${3:-"unknown-mark"}
COMMAND=${4:-""}

# Define window properties based on mark name
set_window_properties() {
    case "$MARK_NAME" in
        "terminal")
            swaymsg "[con_mark=\"$MARK_NAME\"] resize set width 100ppt height 50ppt, move position 0 50ppt"
            ;;
        "music")
            swaymsg "[con_mark=\"$MARK_NAME\"] resize set width 80ppt height 40ppt, move position center, move up 45ppt"
            ;;
        "explorer")
            swaymsg "[con_mark=\"$MARK_NAME\"] resize set width 100ppt height 50ppt, move position center"
            ;;
    esac
}

# Check if the container is already marked
is_running=$(swaymsg -t get_tree | jq ".. | objects | select(.marks? != null and (.marks | index(\"$MARK_NAME\")))" | wc -l)

if [ "$is_running" -ge 1 ]; then
    # Toggle visibility - show window and apply properties
    swaymsg "[con_mark=\"$MARK_NAME\"] scratchpad show"
    set_window_properties
else
    if [ -z "$COMMAND" ]; then
        echo "Error: No command provided to launch application"
        exit 1
    fi

    # Launch application - Sway's rules will handle marking and moving to scratchpad
    eval "$COMMAND" &
    
    # Wait a moment for the application to launch and rules to apply
    sleep 0.5
    
    # Show the scratchpad window and set properties
    swaymsg "[con_mark=\"$MARK_NAME\"] scratchpad show"
    set_window_properties
fi
