#!/usr/bin/env bash

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
STOW_DIR="$SCRIPT_DIR/stow"
UTILS_DIR="$SCRIPT_DIR/utils"

# Source global functions
GLOBAL_SH="$UTILS_DIR/global.sh"
if [ -f "$GLOBAL_SH" ]; then
    source "$GLOBAL_SH"
else
    # Fallback logging if global.sh is not available
    log() {
        local level="$1"
        local msg="$2"
        echo "[$level] $msg"
    }
fi

# Target directories for stowing
declare -A TARGET_DIRS=(
    ["zsh"]="$HOME"
    # ["browsers"]="$HOME/.config"
    # ["udev"]="/etc/udev/rules.d"
    # ["network"]="/etc/systemd/network"
    # ["iwd"]="/etc/iwd"
    # ["resolv"]="/etc"
    # ["sway"]="$HOME/.config/sway"
    # ["rofi"]="$HOME/.config/rofi"
    # ["mpd"]="$HOME/.config/mpd"
    # ["ncmpcpp"]="$HOME/.config/ncmpcpp"
    # ["kitty"]="$HOME/.config/kitty"
    ["rtorrent"]="/home/shad"
)

# Command-line arguments
USERNAME=""

# Print usage information
usage() {
    echo "Usage: $0 --username USERNAME"
    echo ""
    echo "Options:"
    echo "  --username USERNAME  Username to replace 'shad' with in all files (mandatory)"
    echo ""
    echo "If USERNAME is 'shad', no replacement will be performed"
    exit 1
}

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    log "error" "Missing required --username parameter"
    usage
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            if [[ -n "$2" && "${2:0:1}" != "-" ]]; then
                USERNAME="$2"
                shift 2
            else
                log "error" "--username requires a non-empty argument"
                usage
            fi
            ;;
        *)
            log "error" "Unknown option: $1"
            usage
            ;;
    esac
done

# Verify username was provided
if [[ -z "$USERNAME" ]]; then
    log "error" "Username must be provided with --username"
    usage
fi

# Logging function if global.sh wasn't loaded
if ! command -v log >/dev/null 2>&1; then
    log() {
        local level="$1"
        local msg="$2"
        echo "[$level] $msg"
    }
fi

# Function to check if sudo is available
check_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        log "error" "sudo is required but not installed"
        exit 1
    fi
}

# Function to request sudo permission
request_sudo() {
    log "info" "Requesting sudo permission for system operations..."
    if ! sudo -v; then
        log "error" "Failed to get sudo permission"
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
        log "info" "Skipping $source_path (doesn't exist or is a symlink)"
        return
    fi

    # Create backup directory structure
    mkdir -p "$(dirname "$backup_path")"

    # Backup the file/directory
    log "info" "Backing up $source_path to $backup_path"
    if [[ "$use_sudo" == "true" ]]; then
        sudo cp -r "$source_path" "$backup_path"
    else
        cp -r "$source_path" "$backup_path"
    fi

    # Remove the original
    log "info" "Removing original $source_path"
    if [[ "$use_sudo" == "true" ]]; then
        sudo rm -rf "$source_path"
    else
        rm -rf "$source_path"
    fi
}

# Function to process a package
process_package() {
    local package="$1"
    local package_dir="$STOW_DIR/$package"

    if [[ ! -d "$package_dir" ]]; then
        log "info" "Package directory $package_dir does not exist, skipping"
        return
    fi

    log "info" "Processing package: $package"

    # Determine target directory based on package name
    local target_dir=""
    local use_sudo="false"
    for prefix in "${!TARGET_DIRS[@]}"; do
        if [[ "$package" == "$prefix"* ]]; then
            target_dir="${TARGET_DIRS[$prefix]}"
            # Ensure $HOME is expanded to absolute path
            target_dir="${target_dir/#\$HOME/$HOME}"
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
        log "info" "No target directory mapping found for package $package, skipping"
        return
    fi

    # Make sure target directory exists
    if [[ ! -d "$target_dir" ]]; then
        log "info" "Target directory $target_dir does not exist, creating it"
        if [[ "$use_sudo" == "true" ]]; then
            sudo mkdir -p "$target_dir"
        else
            mkdir -p "$target_dir"
        fi
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
    log "info" "Stowing package $package to $target_dir (absolute path)"
    if [[ "$use_sudo" == "true" ]]; then
        sudo stow --dir="$STOW_DIR" --target="$target_dir" --adopt --verbose=2 --no-folding "$package"
    else
        stow --dir="$STOW_DIR" --target="$target_dir" --adopt --verbose=2 --no-folding "$package"
    fi
}

# Function to replace username in files
replace_username() {
    local new_username="$1"
    local old_username="shad"
    
    log "info" "Searching for hardcoded username '$old_username' in $STOW_DIR"
    log "info" "Will replace with: $new_username"
    
    # Find all text files and replace the username
    log "info" "Searching for files containing '$old_username'..."
    
    # Count of files modified
    local modified_files=0
    
    # Find files containing the old username
    local matched_files=$(grep -l -r "$old_username" "$STOW_DIR" 2>/dev/null || true)
    
    if [ -z "$matched_files" ]; then
        log "info" "No files containing '$old_username' were found"
        return
    fi
    
    echo "$matched_files" | while read -r file; do
        # Skip binary files and non-regular files
        if [ ! -f "$file" ] || [ -z "$(file --mime "$file" | grep -E 'text|empty')" ]; then
            continue
        fi
        
        # Create backup file
        cp "$file" "${file}.bak"
        
        # Replace username
        if sed -i "s|$old_username|$new_username|g" "$file"; then
            # Count occurrences of old username in the file
            local count=$(grep -o "$old_username" "${file}.bak" | wc -l)
            if [ "$count" -gt 0 ]; then
                log "success" "Updated $file ($count occurrences)"
                modified_files=$((modified_files + 1))
            else
                # If no changes were made, restore backup
                mv "${file}.bak" "$file"
            fi
        else
            log "error" "Failed to update $file"
            # Restore backup on failure
            mv "${file}.bak" "$file"
        fi
        
        # Remove backup file if it still exists
        if [ -f "${file}.bak" ]; then
            rm "${file}.bak"
        fi
    done
    
    log "success" "Username replacement completed. Modified $modified_files files."
}

# Main execution
main() {
    log "info" "Starting dotfiles backup and stow process"

    # Replace username if not "shad"
    if [[ "$USERNAME" != "shad" ]]; then
        log "info" "Replacing username 'shad' with '$USERNAME'"
        replace_username "$USERNAME"
    else
        log "info" "Username is already 'shad', skipping replacement"
    fi

    # Process each package
    for package in "$STOW_DIR"/*; do
        if [[ -d "$package" ]]; then
            process_package "$(basename "$package")"
        fi
    done

    log "success" "Backup and stow process completed successfully"
}

# Run the main function
main
