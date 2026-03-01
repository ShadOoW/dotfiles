#!/bin/sh
# Wrapper script to get CWD at execution time (not config parse time)
# Add small delay to avoid race condition with compositor during focus changes

LOCK_FILE="/tmp/kitty-cwd.lock"

# Prevent rapid re-execution (common during key repeat)
if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)))
    if [ "$LOCK_AGE" -lt 1 ]; then
        exec kitty  # Just open kitty without CWD
    fi
fi
touch "$LOCK_FILE"

# Small delay to allow compositor to stabilize after focus changes
sleep 0.05

CWD=$(~/.config/sway/scripts/swaycwd.sh 2>/dev/null || echo "$HOME")
exec kitty --working-directory "$CWD"
