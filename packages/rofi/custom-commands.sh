#!/usr/bin/env bash

# Custom Commands Launcher for Rofi
# Simplified version for sway keybinding use

set -euo pipefail

# Define commands: "Name|Command"
declare -a COMMANDS=(
    " ChatGPT|env QT_QPA_PLATFORM=xcb qutebrowser --target window --qt-arg name chatgpt-browser https://chatgpt.com &"
    "󰭻 WhatsApp|env QT_QPA_PLATFORM=xcb qutebrowser --target window --qt-arg name whatsapp-browser https://web.whatsapp.com &"
    "󰖬 Wiki|env QT_QPA_PLATFORM=xcb qutebrowser --target window --qt-arg name wiki-browser http://localhost:2001 &"
    " Wiki Dev Environment|~/.config/dotfiles/packages/sway/scripts/start-wiki-dev.sh &"
    " Kill Window|swaymsg kill"
    " System Update|kitty -e sudo pacman -Syu &"
    " Disk Usage|kitty -e ncdu / &"
    " Network Monitor|kitty -e nethogs &"
    " Process Monitor|kitty -e btop &"
)

# Extract command names for rofi display
get_command_names() {
    printf '%s\n' "${COMMANDS[@]}" | cut -d'|' -f1
}

# Find command by name
get_command_by_name() {
    local name="$1"
    for cmd in "${COMMANDS[@]}"; do
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
    if [[ "$cmd" == *"qutebrowser"* ]] || [[ "$cmd" == *"thunar"* ]] || [[ "$cmd" == *"pavucontrol"* ]] || [[ "$cmd" == *"spotify"* ]] || [[ "$cmd" == *"firefox"* ]] || [[ "$cmd" == *"code"* ]]; then
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
