#!/bin/bash
set -e

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Pacman configuration file
pacman_conf="/etc/pacman.conf"
log "info" "Enhancing pacman configuration"

# Features to enable in pacman.conf
features=(
    "Color"
    "CheckSpace"
    "VerbosePkgLists"
    "ParallelDownloads"
)

# Enable features
for feature in "${features[@]}"; do
    if grep -q "^#$feature" "$pacman_conf"; then
        sudo sed -i "s/^#$feature/$feature/" "$pacman_conf"
        log "info" "Enabled: ${C_ACCENT}$feature${RESET}"
    else
        log "info" "${C_ACCENT}$feature${RESET} is already enabled"
    fi
done

# Add ILoveCandy
if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
    log "info" "Added ${C_ACCENT}ILoveCandy${RESET} to pacman.conf"
else
    log "info" "${C_ACCENT}ILoveCandy${RESET} already present"
fi

# Enable multilib repository
if grep -q "^\[multilib\]" "$pacman_conf"; then
    log "info" "${C_ACCENT}Multilib${RESET} repository is already enabled"
else
    log "info" "Enabling ${C_ACCENT}multilib${RESET} repository"
    sudo sed -i '/#\[multilib\]/,+1 s/^#//' "$pacman_conf"
fi

# Install and configure reflector
if ! command -v reflector &>/dev/null; then
    log "info" "Installing reflector"
    install_package_pacman "reflector" || exit 1
fi

# Update mirrorlist
log "info" "Optimizing mirrorlist using reflector"
country=$(curl -s https://ipapi.co/country/)
if ! sudo reflector --country "$country" --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
    log "error" "Failed to update mirrorlist"
    exit 1
fi

# Sync repositories
log "info" "Synchronizing Pacman repositories"
if ! sudo pacman -Sy; then
    log "error" "Failed to sync repositories"
    exit 1
fi

log "success" "Pacman configuration and optimization completed"
