#!/bin/bash

# Check if Rofi is running
if pgrep -x rofi > /dev/null; then
    # Kill Rofi
    pkill -x rofi
else
    # Launch Rofi (you can change 'drun' to 'run', 'window', etc.)
    rofi -show drun
fi
