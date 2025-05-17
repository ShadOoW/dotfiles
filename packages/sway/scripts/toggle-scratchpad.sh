#!/bin/bash

# Usage: toggle-scratchpad.sh [mark_name] [app_id_type] [app_id] [command] [width_pct] [height_pct] [offset_y_pct]
#
# mark_name:   Name for the mark (e.g., terminal, music, explorer)
# app_id_type: Type of selector to use (app_id, class, or instance)
# app_id:      Value of the selector (e.g., terminal-mark, music-mark, explorer-mark)
# command:     Command to launch the application
# width_pct:   Width as percentage of screen (default: 100)
# height_pct:  Height as percentage of screen (default: 50)
# offset_y_pct: Y position as percentage of screen (default: 0)

# Set default values
MARK_NAME=${1:-"unknown"}
APP_ID_TYPE=${2:-"app_id"}
APP_ID=${3:-"unknown-mark"}
COMMAND=${4:-""}
WIDTH_PCT=${5:-100}
HEIGHT_PCT=${6:-50}
OFFSET_Y_PCT=${7:-0}

# Check if the container is already marked
is_running=$(swaymsg -t get_tree | jq ".. | objects | select(.marks? != null and (.marks | index(\"$MARK_NAME\")))" | wc -l)

if [ "$is_running" -ge 1 ]; then
    # Toggle visibility
    swaymsg "[con_mark=\"$MARK_NAME\"] scratchpad show"
else
    if [ -z "$COMMAND" ]; then
        echo "Error: No command provided to launch application"
        exit 1
    fi

    # Launch application
    eval "$COMMAND" &

    # Build the selector query based on app_id_type
    JQ_SELECTOR=""
    if [ "$APP_ID_TYPE" = "class" ]; then
        # For XWayland applications
        JQ_SELECTOR=".. | objects | select(.window_properties?.class == \"$APP_ID\")"
        # If we have an instance name from --name, add that to the selector
        if [[ "$COMMAND" == *"--name"* ]]; then
            INSTANCE_NAME=$(echo "$COMMAND" | grep -o '\--name [^ ]*' | cut -d' ' -f2)
            if [ -n "$INSTANCE_NAME" ]; then
                JQ_SELECTOR=".. | objects | select(.window_properties?.class == \"$APP_ID\" and .window_properties?.instance == \"$INSTANCE_NAME\")"
            fi
        fi
    else
        # For native Wayland applications
        JQ_SELECTOR=".. | objects | select(.$APP_ID_TYPE == \"$APP_ID\")"
    fi

    # Wait for the window to appear with a more robust approach
    for i in {1..10}; do
        sleep 0.3
        if swaymsg -t get_tree | jq -e "$JQ_SELECTOR" > /dev/null; then
            break
        fi
    done

    # Get screen dimensions (first output)
    read screen_x screen_y screen_w screen_h <<< $(swaymsg -t get_outputs | jq -r '.[0].rect | "\(.x) \(.y) \(.width) \(.height)"')

    # Convert to pixels
    win_w=$((screen_w * WIDTH_PCT / 100))
    win_h=$((screen_h * HEIGHT_PCT / 100))
    win_x=$((screen_x + (screen_w - win_w) / 2))
    win_y=$((screen_y + (screen_h * OFFSET_Y_PCT / 100)))

    # Construct the window criteria based on app_id_type
    if [ "$APP_ID_TYPE" = "class" ]; then
        if [[ "$COMMAND" == *"--name"* ]]; then
            INSTANCE_NAME=$(echo "$COMMAND" | grep -o '\--name [^ ]*' | cut -d' ' -f2)
            if [ -n "$INSTANCE_NAME" ]; then
                CRITERIA="[class=\"$APP_ID\" instance=\"$INSTANCE_NAME\"]"
            else
                CRITERIA="[class=\"$APP_ID\"]"
            fi
        else
            CRITERIA="[class=\"$APP_ID\"]"
        fi
    else
        CRITERIA="[$APP_ID_TYPE=\"$APP_ID\"]"
    fi

    # Apply all layout operations in a single command to prevent window jumping
    swaymsg "$CRITERIA mark $MARK_NAME, move to scratchpad, scratchpad show, floating enable, \
             resize set width ${WIDTH_PCT}ppt height ${HEIGHT_PCT}ppt, \
             move position ${win_x} ${win_y}, \
             border pixel 4, border color #7dcfff"
fi
