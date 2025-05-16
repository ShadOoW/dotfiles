#!/bin/bash
set -e

# GTK themes and icons
aur_packages=(
    tela-circle-icon-theme-all-git
    layan-gtk-theme-git
    whitesur-cursor-theme-git
    whitesur-icon-theme-git
    candy-icons-git
    reversal-icon-theme-git
    nordzy-icon-theme
    bibata-cursor-git
    oreo-cursors-git
    volantes-cursors-git
    papirus-icon-theme-git
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install themes and icons
log "info" "Installing GTK themes, icons and cursors"
install_packages_aur "${aur_packages[@]}" || exit 1

log "success" "GTK themes installation completed"

