#!/bin/bash
set -e

pacman_pkg=(
    neovim
    nvim-lazy
    luarocks
    markdownlint-cli2
    vscode-langservers-extracted
    ctags
    pandoc-cli
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install base packages
log "info" "Installing base packages"
install_packages_aur "${pacman_pkg[@]}" || exit 1

# Create Neovim temporary directories
NVIM_DIRS=(
    "/tmp/nvim/swap/"
    "/tmp/nvim/backup/"
    "/tmp/nvim/undo/"
)

log "info" "Creating Neovim temporary directories"
for dir in "${NVIM_DIRS[@]}"; do
    if ! mkdir -p "$dir"; then
        log "error" "Failed to create directory: $dir"
        exit 1
    fi

    # Set permissions to 700 (rwx------)
    if ! chmod 700 "$dir"; then
        log "error" "Failed to set permissions for: $dir"
        exit 1
    fi

    # Verify write permissions
    if ! touch "$dir/test_write" 2>/dev/null; then
        log "error" "Directory not writable: $dir"
        exit 1
    fi
    rm -f "$dir/test_write"

    log "success" "Directory created and writable: $dir"
done

# Install bluetooth packages
log "info" "Installing bluetooth packages"
install_packages_pacman "${blue_pkg[@]}" || exit 1

log "success" "Base installation completed successfully"
