#!/bin/bash
set -e

# LSP servers for Crush AI assistant
# These match the languageServers in packages/crush/config.json
pacman_pkg=(
    # Go
    gopls

    # Rust
    rust-analyzer

    # Python
    pyright

    # Bash
    bash-language-server

    # Lua
    lua-language-server

    # Markdown
    marksman

    # YAML
    yaml-language-server
)

# AUR packages
aur_pkg=(
    # Includes: json, css, html, typescript language servers
    vscode-langservers-extracted

    # JSON (alternative)
    json-lsp
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install pacman packages
log "info" "Installing LSP packages from pacman"
install_packages_pacman "${pacman_pkg[@]}" || true

# Install AUR packages
log "info" "Installing LSP packages from AUR"
install_packages_aur "${aur_pkg[@]}" || true

log "success" "Crush LSP packages installation completed"
