#!/bin/bash
set -e

# Signal CLI for phone-to-desktop messaging (jq for JSON parsing)
pacman_packages=(signal-cli jq)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  log "error" "Failed to source global.sh"
  exit 1
fi

log "info" "Installing Signal CLI"
install_packages_aur "${pacman_packages[@]}" || exit 1

if ! command -v signal-cli >/dev/null; then
  log "error" "Signal CLI installation failed"
  exit 1
fi

log "success" "Signal CLI installed. Link your phone with: signal-cli -u +NUMBER link then enable signal-sync.service service"
