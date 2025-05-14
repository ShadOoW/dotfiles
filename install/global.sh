#!/bin/bash
set -e

# Minimal color palette and icons for better readability
readonly RESET="\033[0m"
readonly BOLD="\033[1m"
readonly DIM="\033[2m"

# Only essential colors
readonly C_INFO="\033[0;34m"    # Blue
readonly C_SUCCESS="\033[0;32m"  # Green
readonly C_WARNING="\033[0;33m"  # Yellow
readonly C_ERROR="\033[0;31m"    # Red
readonly C_ACCENT="\033[0;36m"   # Cyan

# Unicode icons for better visual clarity
readonly ICON_INFO="ℹ"
readonly ICON_SUCCESS="✓"
readonly ICON_WARNING="⚠"
readonly ICON_ERROR="✗"
readonly ICON_ARROW="→"
readonly ICON_PACKAGE="📦"

# Logging functions
log() {
    local level="$1"
    local msg="$2"
    local icon color

    case "$level" in
        "info")    icon=$ICON_INFO;    color=$C_INFO ;;
        "success") icon=$ICON_SUCCESS;  color=$C_SUCCESS ;;
        "warning") icon=$ICON_WARNING;  color=$C_WARNING ;;
        "error")   icon=$ICON_ERROR;    color=$C_ERROR ;;
        *)         icon=$ICON_ARROW;    color=$C_ACCENT ;;
    esac

    echo -e "${color}${icon}${RESET} ${msg}"
}

# Check if a package is installed
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Get the AUR helper (yay or paru)
get_aur_helper() {
    command -v yay || command -v paru || echo "none"
}

# Install a single package with pacman
install_package_pacman() {
    local pkg="$1"
    
    if is_installed "$pkg"; then
        log "info" "Package ${C_ACCENT}${pkg}${RESET} is already installed"
        return 0
    fi

    log "info" "Installing ${C_ACCENT}${pkg}${RESET}"
    if sudo pacman -S --noconfirm "$pkg" &>/dev/null; then
        log "success" "Installed ${C_ACCENT}${pkg}${RESET}"
        return 0
    else
        log "error" "Failed to install ${C_ACCENT}${pkg}${RESET}"
        return 1
    fi
}

# Install multiple packages with pacman
install_packages_pacman() {
    local packages=("$@")
    local to_install=()

    # Check which packages need installation
    for pkg in "${packages[@]}"; do
        if ! is_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done

    # If no packages need installation, exit early
    if [ ${#to_install[@]} -eq 0 ]; then
        log "info" "All packages are already installed"
        return 0
    fi

    # Install packages
    log "info" "Installing packages: ${C_ACCENT}${to_install[*]}${RESET}"
    if sudo pacman -S --noconfirm "${to_install[@]}" &>/dev/null; then
        log "success" "All packages installed successfully"
        return 0
    else
        log "error" "Failed to install some packages"
        return 1
    fi
}

# Install a package using AUR helper
install_package_aur() {
    local pkg="$1"
    local aur_helper
    
    aur_helper=$(get_aur_helper)
    if [ "$aur_helper" = "none" ]; then
        log "error" "No AUR helper found (yay or paru required)"
        return 1
    fi

    if is_installed "$pkg"; then
        log "info" "Package ${C_ACCENT}${pkg}${RESET} is already installed"
        return 0
    fi

    log "info" "Installing ${C_ACCENT}${pkg}${RESET} from AUR"
    if $aur_helper -S --noconfirm "$pkg" &>/dev/null; then
        log "success" "Installed ${C_ACCENT}${pkg}${RESET}"
        return 0
    else
        log "error" "Failed to install ${C_ACCENT}${pkg}${RESET}"
        return 1
    fi
}

# Install multiple packages using AUR helper
install_packages_aur() {
    local packages=("$@")
    local aur_helper
    
    aur_helper=$(get_aur_helper)
    if [ "$aur_helper" = "none" ]; then
        log "error" "No AUR helper found (yay or paru required)"
        return 1
    fi

    for pkg in "${packages[@]}"; do
        install_package_aur "$pkg"
    done
}

# Uninstall a package
uninstall_package() {
    local pkg="$1"

    if ! is_installed "$pkg"; then
        log "info" "Package ${C_ACCENT}${pkg}${RESET} is not installed"
        return 0
    fi

    log "info" "Removing ${C_ACCENT}${pkg}${RESET}"
    if sudo pacman -R --noconfirm "$pkg" &>/dev/null; then
        log "success" "Removed ${C_ACCENT}${pkg}${RESET}"
        return 0
    else
        log "error" "Failed to remove ${C_ACCENT}${pkg}${RESET}"
        return 1
    fi
}

# Enable and start a systemd service
enable_service() {
    local service="$1"
    
    log "info" "Enabling service: ${C_ACCENT}${service}${RESET}"
    if sudo systemctl enable --now "$service" &>/dev/null; then
        log "success" "Service ${C_ACCENT}${service}${RESET} enabled and started"
        return 0
    else
        log "error" "Failed to enable service ${C_ACCENT}${service}${RESET}"
        return 1
    fi
}
