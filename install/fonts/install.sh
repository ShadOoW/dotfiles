#!/bin/bash
set -e

# Font packages
pacman_fonts=(
    adobe-source-code-pro-fonts 
    adobe-source-sans-fonts
    noto-fonts-emoji
    otf-font-awesome 
    ttf-droid 
    ttf-fira-code
    ttf-fantasque-nerd
    ttf-jetbrains-mono-nerd
    ttf-roboto-mono-nerd
    ttf-firacode-nerd
    noto-fonts
    terminus-font
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

log "success" "Font installation completed successfully"
