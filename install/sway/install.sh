#!/bin/bash
set -e

# Sway window manager packages
sway_packages=(
    sway
    swaybg
    swayidle
    swaylock
    sway-git
    autotiling
    wl-clipboard
    cliphist
    grim
    slurp
    jq
    wluma
    brightnessctl
    rofi-wayland
    sway-contrib-git
    iwmenu
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install sway packages
log "info" "Installing Sway packages"
install_packages_aur "${sway_packages[@]}" || exit 1

log "success" "Sway packages installation completed"
