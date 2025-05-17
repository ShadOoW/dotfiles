#!/bin/bash
set -e

# Thunar and related packages
pacman_packages=(
    lf
    xdotool
    xclip
    bat
    ripdrag
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install Lf packages
log "info" "Installing Lf and related packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

log "success" "Lf installation completed"
