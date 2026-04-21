#!/bin/bash
set -e

# ZSH packages only - plugins and binaries now managed by zinit
pacman_packages=(
  zsh
  fzf
  findutils
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  log "error" "Failed to source global.sh"
  exit 1
fi

# Install ZSH packages
log "info" "Installing ZSH packages"
install_packages_aur "${pacman_packages[@]}" || exit 1

# Check if zsh is installed
if ! command -v zsh >/dev/null; then
  log "error" "ZSH installation failed"
  exit 1
fi

log "info" "Note: Most ZSH plugins and tools (atuin, fnm, zoxide, fzf-tab, etc.) are now managed by zinit in .zshenv/.zshrc"
log "success" "ZSH setup completed successfully"
