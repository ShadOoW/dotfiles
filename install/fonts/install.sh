#!/bin/bash
set -e

# Font packages
pacman_fonts=(
    inter-font
    noto-fonts
    otf-monaspace-nerd
    terminus-font
    ttf-jetbrains-mono-nerd
    ttf-firacode-nerd
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install fonts
log "info" "Installing fonts"
install_packages_pacman "${pacman_fonts[@]}" || exit 1

# Set terminus font for console
log "info" "Setting up terminus font for console"
sudo setfont ter-v16n || log "warning" "Failed to set font temporarily"

# Make terminus font permanent
log "info" "Making terminus font permanent"
if [ -f "/etc/vconsole.conf" ]; then
    log "info" "Backing up existing vconsole.conf"
    sudo cp /etc/vconsole.conf /etc/vconsole.conf.bak
fi

# Add the FONT setting to vconsole.conf, preserving other settings
if [ -f "/etc/vconsole.conf" ]; then
    # Check if FONT is already configured
    if grep -q "^FONT=" /etc/vconsole.conf; then
        log "info" "Updating existing FONT setting in vconsole.conf"
        sudo sed -i 's/^FONT=.*/FONT=ter-v16n/' /etc/vconsole.conf
    else
        log "info" "Adding FONT setting to vconsole.conf"
        echo "FONT=ter-v16n" | sudo tee -a /etc/vconsole.conf > /dev/null
    fi
else
    log "info" "Creating new vconsole.conf file"
    echo "FONT=ter-v16n" | sudo tee /etc/vconsole.conf > /dev/null
fi

# Refresh font cache
log "info" "Refreshing font cache"
fc-cache -fv

# Enable nerd-fonts fontconfig aliases (e.g., Monaspace → Monaspice)
log "info" "Enabling nerd-fonts fontconfig aliases"
nerd_conf_src="/usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf"
nerd_conf_dst="/etc/fonts/conf.d/10-nerd-font-symbols.conf"
if [ -f "$nerd_conf_src" ]; then
    if [ -L "$nerd_conf_dst" ]; then
        log "info" "Nerd fonts config already linked"
    else
        sudo ln -sf "$nerd_conf_src" "$nerd_conf_dst" || log "warning" "Failed to link nerd fonts config"
    fi
else
    log "warning" "Nerd fonts config not found at $nerd_conf_src"
fi

log "success" "Font installation completed successfully"
