#!/bin/bash
set -e

# Thunar and related packages
pacman_packages=(
    thunar
    thunar-volman
    tumbler
    ffmpegthumbnailer
    thunar-archive-plugin
    xarchiver
    gvfs
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install Thunar packages
log "info" "Installing Thunar and related packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

log "success" "Thunar installation completed"
