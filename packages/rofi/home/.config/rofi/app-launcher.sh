#!/usr/bin/env bash

set -euo pipefail

declare -A ICONS=(
  ["whatsapp"]="󰊫"
  ["chatgpt"]="󱜸"
  ["gmail"]="󰊫"
  ["youtube"]="󰗃"
  ["reddit"]="󰌀"
  ["discord"]="󰟮"
  ["telegram"]="󰀲"
  ["spotify"]="󰓇"
)

get_icon() {
  local name_lower="$1"
  for key in "${!ICONS[@]}"; do
    if [[ "$name_lower" == *"$key"* ]]; then
      echo "${ICONS[$key]}"
      return
    fi
  done
  echo "󰣇"
}

case "${ROFI_RETV:-0}" in
  0)
    {
      for dir in "$HOME/.local/share/applications" "/usr/share/applications" "/usr/local/share/applications"; do
        [[ -d "$dir" ]] || continue
        for f in "$dir"/*.desktop; do
          [[ -f "$f" ]] || continue

          local no_display name exec_line
          no_display=$(grep -E '^NoDisplay=true' "$f" 2>/dev/null || true)
          [[ -n "$no_display" ]] && continue

          name=$(grep -E '^Name=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
          exec_line=$(grep -E '^Exec=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
          [[ -z "$name" || -z "$exec_line" ]] && continue

          icon=$(get_icon "$(echo "$name" | tr '[:upper:]' '[:lower:]')")
          echo -en "$name\0icon\x1f$icon\0info\x1f$exec_line\n"
        done
      done
      for f in "$HOME/.local/share/applications"/vivaldi-*-*.desktop; do
        [[ -f "$f" ]] || continue
        local name exec_line
        name=$(grep -E '^Name=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
        exec_line=$(grep -E '^Exec=' "$f" 2>/dev/null | head -1 | cut -d= -f2-)
        [[ -z "$name" || -z "$exec_line" ]] && continue
        icon=$(get_icon "$(echo "$name" | tr '[:upper:]' '[:lower:]')")
        echo -en "$name\0icon\x1f$icon\0info\x1f$exec_line\n"
      done
    } | sort -f | awk '!seen[$0]++'
    echo -en "\0prompt\x1fApps\n"
    ;;
  1)
    eval "$ROFI_INFO" &
    ;;
esac
