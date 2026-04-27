#!/bin/bash
# Interactive zoxide jump from within yazi (run via shell --block).
dest=$(zoxide query -i 2>/dev/null) || exit 0
[ -n "$dest" ] && ya emit cd --str "$dest"
