#!/bin/bash
set -e

# Source the global functions script
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Check if yay is already installed
if command -v yay >/dev/null 2>&1; then
    log "info" "yay is already installed"
    exit 0
fi

# Package to install
pkg="yay-bin"
pkg_dir="/tmp/$pkg"

# Remove existing directory if it exists
if [ -d "$pkg_dir" ]; then
    log "info" "Removing existing directory $pkg_dir"
    rm -rf "$pkg_dir"
fi

# Clone the AUR repo
log "info" "Cloning ${C_ACCENT}$pkg${RESET} from AUR"
if ! git clone "https://aur.archlinux.org/$pkg.git" "$pkg_dir"; then
    log "error" "Failed to clone ${C_ACCENT}$pkg${RESET} from AUR"
    exit 1
fi

# Enter directory and build package
cd "$pkg_dir" || {
    log "error" "Failed to enter ${C_ACCENT}$pkg${RESET} directory"
    exit 1
}

# Build and install package
log "info" "Building and installing ${C_ACCENT}$pkg${RESET}"
if ! makepkg -si --noconfirm; then
    log "error" "Failed to install ${C_ACCENT}$pkg${RESET}"
    cd - >/dev/null
    exit 1
fi

cd - >/dev/null

# Cleanup
if [ -d "$pkg_dir" ]; then
    log "info" "Cleaning up build directory"
    rm -rf "$pkg_dir"
fi

# Verify installation
if ! command -v yay >/dev/null 2>&1; then
    log "error" "yay not found after installation"
    exit 1
fi

# Update system
log "info" "Performing full system update"
if ! yay -Syu --noconfirm; then
    log "error" "System update failed"
    exit 1
fi

log "success" "yay installed and system updated successfully"