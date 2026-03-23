#!/bin/bash
set -e

pacman_pkg=(
    yazi
    ffmpegthumbnailer
    mediainfo
    ouch
    fd
    ripgrep
    zoxide
    poppler
    imagemagick
    jq
)

aur_pkg=(
    ripdrag
    glow
    tig
    resvg
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    echo "error: Failed to source global.sh"
    exit 1
fi

log "info" "Installing Yazi packages"
install_packages_pacman "${pacman_pkg[@]}" || exit 1
install_packages_aur "${aur_pkg[@]}" || exit 1

log "success" "Yazi packages installation completed"
log "info" "Run packages/yazi/setup.sh to install plugins and theme"
