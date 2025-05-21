#!/bin/bash
set -e

pacman_pkg=(
    neovim
    nvim-lazy
    luarocks
    markdownlint-cli2
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install base packages
log "info" "Installing base packages"
install_packages_aur "${pacman_pkg[@]}" || exit 1

# Install bluetooth packages
log "info" "Installing bluetooth packages"
install_packages_pacman "${blue_pkg[@]}" || exit 1

log "success" "Base installation completed successfully"
