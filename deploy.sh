#!/usr/bin/env bash

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
PACKAGES_DIR="$SCRIPT_DIR/packages"

# Target directories for stowing
declare -A TARGET_DIRS=(
    ["zsh"]="$HOME"
    ["browsers"]="$HOME/.config"
    ["udev"]="/etc/udev/rules.d"
    ["network"]="/etc/systemd/network"
)

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if sudo is available
check_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        log "Error: sudo is required but not installed"
        exit 1
    fi
}

# Function to request sudo permission
request_sudo() {
    log "Requesting sudo permission for system operations..."
    if ! sudo -v; then
        log "Error: Failed to get sudo permission"
        exit 1
    fi
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to backup a file or directory
backup_item() {
    local source_path="$1"
    local target_path="$2"
    local relative_path="${target_path#$HOME/}"
    local backup_path="$BACKUP_DIR/$relative_path"
    local use_sudo="$3"

    # Skip if source doesn't exist or is a symlink
    if [[ ! -e "$source_path" ]] || [[ -L "$source_path" ]]; then
        log "Skipping $source_path (doesn't exist or is a symlink)"
        return
    fi

    # Create backup directory structure
    mkdir -p "$(dirname "$backup_path")"

    # Backup the file/directory
    log "Backing up $source_path to $backup_path"
    if [[ "$use_sudo" == "true" ]]; then
        sudo cp -r "$source_path" "$backup_path"
    else
        cp -r "$source_path" "$backup_path"
    fi

    # Remove the original
    log "Removing original $source_path"
    if [[ "$use_sudo" == "true" ]]; then
        sudo rm -rf "$source_path"
    else
        rm -rf "$source_path"
    fi
}

# Function to process a package
process_package() {
    local package="$1"
    local package_dir="$PACKAGES_DIR/$package"

    if [[ ! -d "$package_dir" ]]; then
        log "Package directory $package_dir does not exist, skipping"
        return
    fi

    log "Processing package: $package"

    # Determine target directory based on package name
    local target_dir=""
    local use_sudo="false"
    for prefix in "${!TARGET_DIRS[@]}"; do
        if [[ "$package" == "$prefix"* ]]; then
            target_dir="${TARGET_DIRS[$prefix]}"
            # Check if this is a system directory that requires sudo
            if [[ "$target_dir" == "/etc"* ]]; then
                use_sudo="true"
                check_sudo
                request_sudo
            fi
            break
        fi
    done

    if [[ -z "$target_dir" ]]; then
        log "No target directory mapping found for package $package, skipping"
        return
    fi

    # Process each file/directory in the package
    while IFS= read -r -d '' item; do
        local relative_path="${item#$package_dir/}"
        local target_path="$target_dir/$relative_path"

        if [[ -e "$target_path" ]]; then
            backup_item "$target_path" "$target_path" "$use_sudo"
        fi
    done < <(find "$package_dir" -mindepth 1 -print0)

    # Stow the package to its specific target directory
    log "Stowing package $package to $target_dir"
    if [[ "$use_sudo" == "true" ]]; then
        sudo stow --dir="$PACKAGES_DIR" --target="$target_dir" --adopt --verbose=2 "$package"
    else
        stow --dir="$PACKAGES_DIR" --target="$target_dir" --adopt --verbose=2 "$package"
    fi
}

# Main execution
main() {
    log "Starting dotfiles backup and stow process"

    # Process each package
    for package in "$PACKAGES_DIR"/*; do
        if [[ -d "$package" ]]; then
            process_package "$(basename "$package")"
        fi
    done

    log "Backup and stow process completed successfully"
}

# Run the main function
main
