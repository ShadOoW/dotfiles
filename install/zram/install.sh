#!/bin/bash
set -e

# zram packages
pacman_pkg=(
    zram-generator
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install zram packages
log "info" "Installing zram packages"
install_packages_pacman "${pacman_pkg[@]}" || exit 1

log "success" "zram installation completed successfully"
