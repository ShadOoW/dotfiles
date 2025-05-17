#!/bin/bash

# Define variables
RECORDINGS_DIR="$HOME/Videos/Recordings"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="recording_$TIMESTAMP.mp4"
OUTPUT_PATH="$RECORDINGS_DIR/$FILENAME"

# Ensure the recordings directory exists
mkdir -p "$RECORDINGS_DIR"

# Check if wl-screenrec is already running
if pgrep -x "wl-screenrec" > /dev/null; then
    # Kill the recording process
    pkill -x "wl-screenrec"
    
    # Notify user that recording has stopped
    notify-send "Screen Recording" "Recording stopped and saved to $OUTPUT_PATH" -i video-x-generic
    
    # Update waybar
    pkill -RTMIN+4 waybar
else
    # Prompt user to select an area to record
    GEOMETRY=$(slurp -d)
    
    if [ -n "$GEOMETRY" ]; then
        # Start recording with the selected geometry
        notify-send "Screen Recording" "Recording started..." -i media-record
        
        # Echo JSON format for waybar custom module
        echo '{"text": "", "class": "recording", "tooltip": "Recording in progress - Click to stop"}'
        
        # Update waybar
        pkill -RTMIN+4 waybar
        
        # Start recording in the background
        wl-screenrec -g "$GEOMETRY" -f "$OUTPUT_PATH" &
    else
        notify-send "Screen Recording" "Recording cancelled" -i dialog-error
    fi
fi
