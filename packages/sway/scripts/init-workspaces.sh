#!/bin/bash

# Initialize all workspaces to make them persistent in Waybar using a single command
# This prevents visible jumping between workspaces

# Create all workspaces in one command and return to workspace 1
swaymsg "workspace 1; workspace 2; workspace 3; workspace 4; workspace 5; workspace 6; workspace 7; workspace 8; workspace 9; workspace 10; workspace 1"
