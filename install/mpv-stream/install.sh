#!/bin/bash
set -e

# Main packages
pacman_packages=(
    mpv
    streamlink
    yt-dlp
)

# Optional AUR packages
aur_packages=(
    mpv-mpris # MPRIS plugin for mpv (for integration with media controls)
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install main packages
log "info" "Installing MPV streaming packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

# Install optional AUR packages
log "info" "Installing auxiliary MPV packages"
install_packages_aur "${aur_packages[@]}" || {
    log "warning" "Could not install some AUR packages, continuing anyway"
}

# Check if yt-dlp works correctly
if ! yt-dlp --version >/dev/null 2>&1; then
    log "warning" "yt-dlp might not be installed correctly"
else
    log "success" "yt-dlp is working correctly"
fi

# Final instructions
log "info" "To stream videos or audio from YouTube: mpv --profile=ytlow 'https://www.youtube.com/watch?v=ZIIT9hO1EZE'"
log "info" "To stream videos or audio from Twitch: mpv --profile=twlow https://www.twitch.tv/ceb_"
log "info" "Check ~/.config/mpv/mpv.conf for all the profiles"
log "success" "MPV streaming setup completed successfully" 
