#!/bin/bash
set -e

# ZSH and related packages
pacman_packages=(
    lsd
    fzf
    zsh
    zsh-completions
    bat
    zoxide
    findutils
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install ZSH packages
log "info" "Installing ZSH and related packages"
install_packages_pacman "${pacman_packages[@]}" || exit 1

# Check if zsh is installed
if ! command -v zsh >/dev/null; then
    log "error" "ZSH installation failed"
    exit 1
fi

# Setup Oh My Zsh
log "info" "Setting up Oh My Zsh and plugins"

# Install Oh My Zsh
if [ ! -d "$HOME/.config/oh-my-zsh" ]; then
    log "info" "Installing Oh My Zsh"
    ZSH="$HOME/.config/oh-my-zsh" sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended --keep-zshrc || {
        log "error" "Failed to install Oh My Zsh"
        exit 1
    }
else
    log "info" "Oh My Zsh is already installed"
fi

# Install autosuggestions plugin
if [ ! -d "$HOME/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    log "info" "Installing zsh-autosuggestions plugin"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions" || {
        log "error" "Failed to install zsh-autosuggestions"
        exit 1
    }
else
    log "info" "zsh-autosuggestions plugin is already installed"
fi

# Install syntax highlighting plugin
if [ ! -d "$HOME/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    log "info" "Installing zsh-syntax-highlighting plugin"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" || {
        log "error" "Failed to install zsh-syntax-highlighting"
        exit 1
    }
else
    log "info" "zsh-syntax-highlighting plugin is already installed"
fi

log "info" "Note: This script only installs ZSH and plugins. It does not modify .zshrc or change the default shell"
log "success" "ZSH setup completed successfully"
