#!/usr/bin/env bash
# Rofi window switcher for Sway - custom modi
set -euo pipefail

# Get PWA name from desktop file
get_pwa_name() {
    local app_id="$1"
    local app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    local f name app_id_short

    if [[ "$app_id" == vivaldi-*-Default ]]; then
        # Extract the ID part: vivaldi-XXXX-Default -> XXXX
        app_id_short=$(echo "$app_id" | sed 's/vivaldi-\(.*\)-Default/\1/')
        
        for f in "$app_dir"/vivaldi-*-Default.desktop; do
            [[ -f "$f" ]] || continue
            if grep -q "app-id=$app_id_short" "$f" 2>/dev/null; then
                name=$(grep -E '^Name=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
                [[ -n "$name" ]] && echo "$name" && return
            fi
        done
    fi
    echo "$app_id"
}

# If argument provided, user made a selection - focus the window
if [ $# -gt 0 ]; then
    winid=$(echo "$1" | sed 's/.*\[\([0-9]*\)\].*/\1/')
    [[ -n "$winid" ]] && swaymsg "[con_id=$winid]" focus
    exit 0
fi

# Output window list
swaymsg -t get_tree | jq -r '
    [.nodes[].nodes[] | select(.type == "workspace") as $ws
    | recurse(.nodes[]?, .floating_nodes[]?)
    | select(.type == "con" or .type == "floating_con")
    | select(.app_id != null)
    | select(.id != null)
    | select($ws.name != "__i3_scratch")
    | "\($ws.name)|\(.id)|\(.app_id)|\(.name)|\(.focused)"
    ] | .[]
' | while IFS='|' read -r ws id app_id name focused; do
    display_name=$(get_pwa_name "$app_id")

    if [ "$focused" = "true" ]; then
        echo "$ws [*] $display_name - $name [$id]"
    else
        echo "$ws [ ] $display_name - $name [$id]"
    fi
done
