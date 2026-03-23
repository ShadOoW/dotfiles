#!/usr/bin/env bash
# Rofi window switcher for Sway - custom modi
set -euo pipefail

# Get icon name for app - check PWA first
get_icon_for_app() {
    local app_id="$1"
    local icon_dir="/home/shad/.config/rofi/icons"
    local app_dir="${XDG_DATA_HOME:-$HOME/.local/share/applications}"
    local name_lower app_id_short f pwa_name

    # Check if it's a vivaldi PWA and get the app name
    if [[ "$app_id" == vivaldi-*-Default ]]; then
        app_id_short=$(echo "$app_id" | sed 's/vivaldi-\(.*\)-Default/\1/')
        for f in "$app_dir"/vivaldi-*-Default.desktop; do
            [[ -f "$f" ]] || continue
            if grep -q "app-id=$app_id_short" "$f" 2> /dev/null; then
                pwa_name=$(grep -E '^Name=' "$f" 2> /dev/null | head -1 | cut -d= -f2-)
                [[ -n "$pwa_name" ]] && name_lower=$(echo "$pwa_name" | tr '[:upper:]' '[:lower:]')
                break
            fi
        done
    else
        name_lower=$(echo "$app_id" | tr '[:upper:]' '[:lower:]')
    fi

    # Map by name for PWAs, otherwise use app_id
    case "$name_lower" in
        *youtube*) echo "$icon_dir/youtube.svg" ;;
        *chatgpt*) echo "$icon_dir/chatgpt.svg" ;;
        *claude*) echo "$icon_dir/claude.svg" ;;
        *whatsapp*) echo "$icon_dir/whatsapp.svg" ;;
        *gmail* | *google-mail*) echo "$icon_dir/gmail.svg" ;;
        *discord*) echo "$icon_dir/discord.svg" ;;
        *slack*) echo 'slack' ;;
        *spotify*) echo 'spotify' ;;
        *notion*) echo 'notion' ;;
        *figma*) echo 'figma' ;;
        *vscode* | *code-oss*) echo 'vscode' ;;
        *terminal*) echo 'terminal' ;;
        *kitty*) echo 'kitty' ;;
        *firefox*) echo 'firefox' ;;
        *thunar*) echo 'thunar' ;;
        *vivaldi*) echo 'vivaldi' ;;
        *libreoffice*) echo 'libreoffice' ;;
        *mpv*) echo 'mpv' ;;
        *zathura*) echo 'zathura' ;;
        *) echo "$app_id" ;;
    esac
}

# Get PWA icon - use get_icon_for_app which handles mapping
get_pwa_icon() {
    local app_id="$1"
    get_icon_for_app "$app_id"
}

# Get PWA name from desktop file
get_pwa_name() {
    local app_id="$1"
    local app_dir="${XDG_DATA_HOME:-$HOME/.local/share/applications}"
    local f name app_id_short

    if [[ "$app_id" == vivaldi-*-Default ]]; then
        app_id_short=$(echo "$app_id" | sed 's/vivaldi-\(.*\)-Default/\1/')

        for f in "$app_dir"/vivaldi-*-Default.desktop; do
            [[ -f "$f" ]] || continue
            if grep -q "app-id=$app_id_short" "$f" 2> /dev/null; then
                name=$(grep -E '^Name=' "$f" 2> /dev/null | head -1 | cut -d= -f2-)
                [[ -n "$name" ]] && echo "$name" && return
            fi
        done
    fi
    echo "$app_id"
}

# Format workspace name - show 10 as 0
format_ws() {
    local ws="$1"
    if [[ "$ws" =~ ^[0-9]+$ ]]; then
        echo $((ws % 10))
    else
        echo "$ws"
    fi
}

# If argument provided or stdin has content, user made a selection - focus the window
if [ $# -gt 0 ]; then
    if [ "$1" = "--focused-index" ]; then
        # Output the index of the focused window (0-based) without sorting
        swaymsg -t get_tree | jq -r '
            [.nodes[].nodes[] | select(.type == "workspace") as $ws
            | recurse(.nodes[]?, .floating_nodes[]?)
            | select(.type == "con" or .type == "floating_con")
            | select(.app_id != null)
            | select(.id != null)
            | select($ws.name != "__i3_scratch")
            | .focused]
            ' | jq -r 'index(true)'
        exit 0
    fi

    # Read selection from argument (rofi passes selected line as argument on Enter)
    selected="$1"

    # Extract container ID from selection (format: "ws name - title <!-- id -->")
    winid=$(echo "$selected" | sed 's/.*<!-- \(.*\) -->.*/\1/')

    # Extract window title for fallback
    title=$(echo "$selected" | sed 's/.* - \(.*\) <!--.*/\1/')

    # Focus the window by container ID, or by title if ID fails
    if ! swaymsg "[con_id=$winid]" focus > /dev/null 2>&1; then
        swaymsg -t get_tree | jq -r "
            [.nodes[].nodes[] | select(.type == \"workspace\")
            | recurse(.nodes[]?, .floating_nodes[]?)
            | select(.type == \"con\" or .type == \"floating_con\")
            | select(.name == \"$title\")
            | .id] | .[0]" | xargs -I{} swaymsg "[con_id={}]" focus > /dev/null 2>&1 || true
    fi
    exit 0
fi

# Output window list with icons (keep original order)
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
    icon=$(get_pwa_icon "$app_id")
    ws_display=$(format_ws "$ws")

    if [ "$focused" = "true" ]; then
        echo -e "$ws_display $display_name - $name <!-- $id -->\u0000icon\u001f$icon"
    else
        echo -e "$ws_display $display_name - $name <!-- $id -->\u0000icon\u001f$icon"
    fi
done
