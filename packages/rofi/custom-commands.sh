#!/usr/bin/env bash

# Custom Commands Launcher for Rofi
# Simplified version for sway keybinding use

set -euo pipefail

# Define commands: "Name|Command"
declare -a COMMANDS=(
    "󰖬 Wiki|qutebrowser --target window --qt-arg name wiki-browser http://localhost:2001 &"
    " Wiki Dev Environment|~/.config/dotfiles/packages/sway/scripts/start-wiki-dev.sh &"
    " Kill Window|swaymsg kill"
    " System Update|kitty -e sudo pacman -Syu &"
    " Disk Usage|kitty -e ncdu / &"
    " Network Monitor|kitty -e nethogs &"
    " Process Monitor|kitty -e btop &"
)

# Icon for Vivaldi PWA by name (case-insensitive); default if no match
vivaldi_icon_for_name() {
    local name_lower
    name_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$name_lower" in
        *whatsapp*) echo '' ;;
        *chatgpt*) echo '󱜸' ;;
        *gmail*) echo '󰊫' ;;
        *) echo '󰣇' ;;
    esac
}

# Vivaldi PWA entries from ~/.local/share/applications/vivaldi-*-*.desktop
declare -a VIVALDI_ENTRIES=()
build_vivaldi_entries() {
    local app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    local f name exec_line icon
    for f in "$app_dir"/vivaldi-*-*.desktop; do
        [[ -f "$f" ]] || continue
        name=$(grep -E '^Name=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
        exec_line=$(grep -E '^Exec=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
        [[ -n "$name" && -n "$exec_line" ]] || continue
        icon=$(vivaldi_icon_for_name "$name")
        VIVALDI_ENTRIES+=("$icon $name|$exec_line")
    done
}
build_vivaldi_entries

# Combined list: static commands first, then Vivaldi PWAs
declare -a ALL_ENTRIES=("${VIVALDI_ENTRIES[@]}" "${COMMANDS[@]}")

# Extract command names for rofi display
get_command_names() {
    printf '%s\n' "${ALL_ENTRIES[@]}" | cut -d'|' -f1
}

# Find command by name
get_command_by_name() {
    local name="$1"
    for cmd in "${ALL_ENTRIES[@]}"; do
        if [[ "${cmd%%|*}" == "$name" ]]; then
            echo "${cmd#*|}"
            return 0
        fi
    done
    return 1
}

# Execute command
execute_command() {
    local cmd="$1"
    
    # Run GUI applications in background
    if [[ "$cmd" == *"qutebrowser"* ]] || [[ "$cmd" == *"thunar"* ]] || [[ "$cmd" == *"pavucontrol"* ]] || [[ "$cmd" == *"spotify"* ]] || [[ "$cmd" == *"firefox"* ]] || [[ "$cmd" == *"code"* ]] || [[ "$cmd" == *"vivaldi"* ]]; then
        eval "$cmd" &
    else
        eval "$cmd"
    fi
}

# Show rofi menu
show_menu() {
    local selected
    selected=$(get_command_names | rofi -dmenu -i -p "󱓞 Commands" -lines 15 -width 60)
    
    if [[ -n "$selected" ]]; then
        local command
        if command=$(get_command_by_name "$selected"); then
            execute_command "$command"
        fi
    fi
}

# Main execution
show_menu
