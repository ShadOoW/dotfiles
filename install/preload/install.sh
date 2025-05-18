#!/bin/bash
set -e

# AUR packages
aur_packages=(
    preload
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    echo "Error: Failed to source global.sh" >&2
    exit 1
fi

# Install Pacman packages
log "info" "Installing Preload from official repositories"
install_packages_aur "${aur_packages[@]}" || exit 1

# Enable and start preload service
log "info" "Enabling and starting preload systemd service"
if systemctl is-active --quiet preload.service; then
    log "info" "Preload service is already active."
else
    if sudo systemctl enable --now preload.service; then
        log "success" "Preload service enabled and started successfully."
    else
        log "error" "Failed to enable/start preload service. Please check systemd logs."
        exit 1 # Exit if service enabling fails, as it's the primary goal
    fi
fi

log "info" "---------------------------------------------------------------------"
log "info" "Preload is now running and will adaptively preload frequently used applications."
log "info" "The configuration file is located at: /etc/preload.conf"
log "info" "Default settings are generally suitable for most users."
log "info" "---------------------------------------------------------------------"

log "success" "Preload installation script finished."
