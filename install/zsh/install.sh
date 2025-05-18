#!/bin/bash
set -e

# ZSH and related packages
pacman_packages=(
    lsd
    fzf
    zsh
    bat
    zoxide
    findutils
    fnm
    zsh-completions
    zsh-history-substring-search
    zsh-autosuggestions
    zsh-fast-syntax-highlighting-git
    zsh-fzf-plugin-git
    fzf-tab-git
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install ZSH packages
log "info" "Installing ZSH and related packages"
install_packages_aur "${pacman_packages[@]}" || exit 1

# Check if zsh is installed
if ! command -v zsh >/dev/null; then
    log "error" "ZSH installation failed"
    exit 1
fi

# Check if fnm is installed
if ! command -v fnm >/dev/null; then
    log "warning" "FNM installation may have failed. If not available, install manually:"
fi

log "info" "Note: This script only installs ZSH and plugins. It does not modify .zshrc or change the default shell"
log "success" "ZSH setup completed successfully"
