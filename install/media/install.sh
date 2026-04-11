#!/bin/bash
set -e

# Pacman packages
pacman_packages=(
  beets
)

# AUR packages
aur_packages=(
  beets-bandcamp
  lidarr
  nicotine+
  prowlarr
  sabnzbd
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  log "error" "Failed to source global.sh"
  exit 1
fi

# Install pacman packages
log "info" "Installing media server packages from pacman"
install_packages_pacman "${pacman_packages[@]}" || exit 1

# Install AUR packages
log "info" "Installing media server packages from AUR"
install_packages_aur "${aur_packages[@]}" || exit 1

# Enable and start lidarr service
log "info" "Enabling and starting lidarr service"
enable_service lidarr || exit 1

# Enable and start prowlarr service
log "info" "Enabling and starting prowlarr service"
enable_service prowlarr || exit 0

log "success" "Media server packages installation completed"

echo ""
log "warning" "Optional: Consider installing the following packages for enhanced functionality:"
echo "  - aria2 (download utility)"
echo "  - One of: rtorrent, transmission, or qbittorrent (torrent client)"
