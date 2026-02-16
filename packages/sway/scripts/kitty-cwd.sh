#!/bin/sh
# Wrapper script to get CWD at execution time (not config parse time)
CWD=$(~/.config/sway/scripts/swaycwd.sh 2>/dev/null || echo "$HOME")
exec kitty --working-directory "$CWD"
