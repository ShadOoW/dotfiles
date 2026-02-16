#!/bin/sh
# Author: Caleb Stewart
# URL: https://github.com/calebstewart/swaycwd.git
# Description: print the CWD of the currently focused window in swaywm
# Modified to handle Floating Terminals and Thunar windows

# Set up logging
LOG_FILE="/tmp/swaycwd.log"
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Clear previous log
> "$LOG_FILE"

# Grab the window/display tree
TREE=$(swaymsg -t get_tree)

# Get the app_id of the focused window
APP_ID=$(echo "$TREE" | jq --raw-output '.. | select(.focused? == true) | .app_id' | head -n1)
log "Focused window app_id: $APP_ID"

# If the focused window is Thunar, try to get directory from window title
if [ "$APP_ID" = "Thunar" ]; then
    # Get the window title
    TITLE=$(echo "$TREE" | jq --raw-output '.. | select(.focused? == true) | .name' | head -n1)
    log "Window title: $TITLE"
    
    # Try to extract directory from title
    # Thunar window titles are typically in format: "directory_name - Thunar"
    if echo "$TITLE" | grep -q " - Thunar$"; then
        # Extract the directory name from the title
        DIR_NAME=$(echo "$TITLE" | sed 's/ - Thunar$//')
        log "Extracted directory name: $DIR_NAME"
        
        # Try to find the directory using zoxide
        if command -v zoxide >/dev/null 2>&1; then
            # Use zoxide query to get the most likely directory
            Z_DIR=$(zoxide query "$DIR_NAME" 2>/dev/null)
            log "Zoxide directory result: $Z_DIR"
            if [ -n "$Z_DIR" ] && [ -d "$Z_DIR" ]; then
                log "Found directory using zoxide: $Z_DIR"
                echo "$Z_DIR"
                exit 0
            fi
        fi
        
        # If zoxide didn't help, try common locations
        for base_dir in "$HOME" "/home/$USER" "/"; do
            potential_path="$base_dir/$DIR_NAME"
            if [ -d "$potential_path" ]; then
                log "Found directory at: $potential_path"
                echo "$potential_path"
                exit 0
            fi
        done
        
        # If we couldn't find the directory, try using the current working directory
        if [ -d "$DIR_NAME" ]; then
            log "Found directory in current working directory: $DIR_NAME"
            echo "$(realpath "$DIR_NAME")"
            exit 0
        fi
    fi
    
    # If we couldn't get the directory from the title, try the command line
    PID=$(echo "$TREE" | jq --raw-output '.. | select(.focused? == true and .pid != null) | .pid' | head -n1)
    log "Thunar PID: $PID"
    
    if [ -n "$PID" ] && [ "$PID" != "null" ]; then
        # Get the command line of the Thunar process
        CMDLINE=$(cat "/proc/$PID/cmdline" 2>/dev/null | tr '\0' ' ')
        log "Thunar command line: $CMDLINE"
        
        # Try to extract the directory from the command line
        if echo "$CMDLINE" | grep -q "thunar"; then
            # Get the last argument which should be the directory
            CWD=$(echo "$CMDLINE" | awk '{print $NF}')
            log "Extracted CWD from command line: $CWD"
            
            # Verify the directory exists
            if [ -d "$CWD" ]; then
                log "Found valid directory: $CWD"
                echo "$CWD"
                exit 0
            else
                log "Extracted directory does not exist: $CWD"
            fi
        fi
    fi
fi

# Use a more robust jq query to find the PID of the focused window.
# --raw-output gives the PID without quotes.
# head -n1 ensures only one PID is processed if multiple somehow match.
PID=$(echo "$TREE" | jq --raw-output '.. | select(.focused? == true and .pid != null) | .pid' | head -n1)
log "Focused window PID: $PID"

# If PID is empty (no focused window with PID found) or the string "null" (from jq if no .pid), then exit.
if [ -z "$PID" ] || [ "$PID" = "null" ]; then
    log "No valid PID found, exiting"
    exit 1 # This will trigger the '|| echo $HOME' in your Sway config
fi

# Original logic for drilling down the process tree:
# This loop tries to find the PID of the shell running in the terminal.
# It assumes the shell is the deepest descendant in the process chain starting from PID.
# pgrep -P "$PID" lists child processes. ">/dev/null" silences pgrep's stdout for the test.
# The PID variable is updated to the last child found in each step.
while pgrep -P "$PID" >/dev/null 2>/dev/null; do
  # Update PID to the last child process. Silenced pgrep's stderr here too.
  NEW_PID=$(pgrep -P "$PID" 2>/dev/null | tail -n1)
  # Guard against empty PID (race condition: process exited between check and read)
  if [ -z "$NEW_PID" ]; then
    break
  fi
  PID="$NEW_PID"
  log "Updated PID to: $PID"
done

# Show the current working directory.
# readlink -e prints the canonicalized absolute pathname.
# If it fails (e.g., PID doesn't exist or /proc/$PID/cwd is a broken symlink),
# it prints nothing to stdout and returns 1.
CWD=$(readlink -e "/proc/$PID/cwd")
log "Final CWD from /proc: $CWD"

if [ -n "$CWD" ]; then
    echo "$CWD"
    exit 0
else
    log "No CWD found, exiting"
    exit 1 # Triggers '|| echo $HOME'
fi
