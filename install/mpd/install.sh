#!/bin/bash
set -e

# MPD and client packages
pacman_packages=(
    mpd
    mpc
    ncmpcpp
)

# Optional visualization packages
aur_packages=(
    cli-visualizer
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install MPD packages
log "info" "Installing MPD and related packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

# Install visualization tools (optional)
log "info" "Installing audio visualization tools"
install_packages_aur "${aur_packages[@]}" || {
    log "warning" "Could not install some AUR packages, continuing anyway"
}

# Create required directories
log "info" "Creating required directories for MPD"
mkdir -p "$HOME/.config/mpd/playlists" || {
    log "error" "Failed to create MPD directories"
    exit 1
}

# Enable and start MPD service
log "info" "Enabling MPD service for current user"
if ! systemctl --user enable --now mpd.service; then
    log "error" "Failed to enable MPD service"
    exit 1
fi

# Check if MPD is running correctly
if ! mpc status >/dev/null 2>&1; then
    log "warning" "MPD service might not be running correctly. Check with: systemctl --user status mpd"
else
    log "success" "MPD service is running"
fi

# Final instructions
log "info" "Use Stow to install the MPD configuration files, set the path to your music in the mpd.conf file"
log "info" "To use run: ncmpcpp"
log "success" "MPD installation completed successfully"
