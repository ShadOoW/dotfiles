#!/bin/bash
set -e

# Audio packages
pipewire_packages=(
    pipewire
    wireplumber
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    sof-firmware
    pavucontrol
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Disable PulseAudio
log "info" "Disabling PulseAudio services"
systemctl --user disable --now pulseaudio.socket pulseaudio.service &>/dev/null || true

# Install Pipewire packages
log "info" "Installing Pipewire packages"
install_packages_pacman "${pipewire_packages[@]}" || exit 1

# Ensure pipewire-pulse is properly installed (sometimes needs reinstall)
log "info" "Reinstalling pipewire-pulse to ensure proper setup"
install_package_pacman "pipewire-pulse" || exit 1

# Enable Pipewire services
log "info" "Enabling Pipewire services"
services=(
    "pipewire.socket"
    "pipewire-pulse.socket"
    "wireplumber.service"
    "pipewire.service"
)

for service in "${services[@]}"; do
    if ! systemctl --user enable --now "$service" &>/dev/null; then
        log "error" "Failed to enable $service"
        exit 1
    fi
done

log "success" "Pipewire installation and setup completed"
