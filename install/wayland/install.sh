#!/bin/bash
set -e

# Wayland packages
wayland_packages=(
    # Rofi
    rofi-wayland

    # Clipboard
    wl-clipboard
    cliphist

    # Appearance
    nwg-look
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install wayland packages
log "info" "Installing Wayland packages"
install_packages_aur "${wayland_packages[@]}" || exit 1

log "success" "Wayland packages installation completed"
