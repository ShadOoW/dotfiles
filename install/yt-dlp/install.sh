#!/bin/bash
set -e

# yt-dlp and related packages
pacman_packages=(
    yt-dlp
    ffmpeg
    imagemagick
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install yt-dlp packages
log "info" "Installing yt-dlp and related packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

log "success" "yt-dlp installation completed"
