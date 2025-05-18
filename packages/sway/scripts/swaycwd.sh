#!/bin/sh
# Author: Caleb Stewart
# URL: https://github.com/calebstewart/swaycwd.git
# Description: print the CWD of the currently focused window in swaywm
# Modified to handle FLoating Terminals

# Grab the window/display tree
TREE=$(swaymsg -t get_tree)

# Use a more robust jq query to find the PID of the focused window.
# --raw-output gives the PID without quotes.
# head -n1 ensures only one PID is processed if multiple somehow match.
PID=$(echo "$TREE" | jq --raw-output '.. | select(.focused? == true and .pid != null) | .pid' | head -n1)

# If PID is empty (no focused window with PID found) or the string "null" (from jq if no .pid), then exit.
if [ -z "$PID" ] || [ "$PID" = "null" ]; then
    exit 1 # This will trigger the '|| echo $HOME' in your Sway config
fi

# Original logic for drilling down the process tree:
# This loop tries to find the PID of the shell running in the terminal.
# It assumes the shell is the deepest descendant in the process chain starting from PID.
# pgrep -P "$PID" lists child processes. ">/dev/null" silences pgrep's stdout for the test.
# The PID variable is updated to the last child found in each step.
while pgrep -P "$PID" >/dev/null 2>/dev/null; do # Silenced pgrep's stderr for cleaner operation
  # Update PID to the last child process. Silenced pgrep's stderr here too.
  PID=$(pgrep -P "$PID" 2>/dev/null | tail -n1)
done

# Show the current working directory.
# readlink -e prints the canonicalized absolute pathname.
# If it fails (e.g., PID doesn't exist or /proc/$PID/cwd is a broken symlink),
# it prints nothing to stdout and returns 1.
CWD=$(readlink -e "/proc/$PID/cwd")

if [ -n "$CWD" ]; then
    echo "$CWD"
    exit 0
else
    exit 1 # Triggers '|| echo $HOME'
fi
