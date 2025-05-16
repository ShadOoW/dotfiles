#!/usr/bin/env bash

# Ensure grim and slurp are installed (for Sway)
check() {
  command -v "$1" >/dev/null 2>&1
}

# Check if the required commands are installed
check grim || { echo "grim is not installed"; exit 1; }
check slurp || { echo "slurp is not installed"; exit 1; }
check wl-copy || { echo "wl-copy is not installed"; exit 1; }

# Use slurp to select a region, then capture the color with grim
color=$(grim -g "$(slurp)" - | convert - -format "%[pixel:p{0,0}]" txt:- | tail -n 1 | cut -d ' ' -f 3)

# Copy the color to the clipboard using wl-copy
echo "$color" | wl-copy

# Optionally print the color (for debugging or feedback)
echo "Selected color: $color"
