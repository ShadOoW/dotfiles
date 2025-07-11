#!/bin/bash
set -e

# Qutebrowser and related packages
pacman_packages=(
    qutebrowser
    python-adblock
    hunspell-en_us
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
