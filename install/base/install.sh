#!/bin/bash
set -e

# Base development packages
pacman_pkg=(
    kitty
    nvm
    base-devel
    findutils
    stow
    btop
    iwd
    debugedit
    git
    fakeroot
    archlinux-keyring
    zip
    unzip
    polkit-gnome
    xorg-xhost
    gparted
)

# Bluetooth related packages
blue_pkg=(
    bluez
    bluez-utils
    blueman
)


# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
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

log "success" "Base installation completed successfully"
