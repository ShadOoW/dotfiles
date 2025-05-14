#!/bin/bash
set -e

# Base development packages
pacman_pkg=(
    base-devel
    stow
    btop
    iwd
    debugedit
    git
    fakeroot
    archlinux-keyring
    zip
    unzip
)

# Bluetooth related packages
blue_pkg=(
    bluez
    bluez-utils
    blueman
)

# Font packages
pacman_fonts=(
    adobe-source-code-pro-fonts 
    noto-fonts-emoji
    otf-font-awesome 
    ttf-droid 
    ttf-fira-code
    ttf-fantasque-nerd
    ttf-jetbrains-mono 
    ttf-jetbrains-mono-nerd
    ttf-roboto-mono-nerd
    ttf-firacode-nerd
    noto-fonts
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install base packages
log "info" "Installing base packages"
install_packages_pacman "${pacman_pkg[@]}" || exit 1

# Install bluetooth packages
log "info" "Installing bluetooth packages"
install_packages_pacman "${blue_pkg[@]}" || exit 1

# Enable bluetooth service
enable_service "bluetooth.service" || exit 1

# Install fonts
log "info" "Installing fonts"
install_packages_pacman "${pacman_fonts[@]}" || exit 1

log "success" "Base installation completed successfully"
