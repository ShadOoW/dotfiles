#!/bin/bash
set -e

# GTK themes and icons
aur_packages=(
  # GTK engine and build tools
  gtk-engine-murrine
  sassc
  gnome-themes-extra

  # GTK themes (used in nvim/config)
  tokyonight-gtk-theme-git

  # GTK themes (used in gtk3 settings)
  catppuccin-gtk-theme-macchiato

  # Icons (used in gtk3 settings)
  candy-icons-git

  # Cursors (used in gtk3 settings)
  bibata-cursor-theme
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
