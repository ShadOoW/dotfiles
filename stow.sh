#!/usr/bin/env bash

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
STOW_DIR="$SCRIPT_DIR/packages"
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
    ["zsh", "rtorrent"]="$HOME"
    ["browsers", "mimeapps", "user-dirs"]="$HOME/.config"
    ["udev"]="/etc/udev/rules.d"
    ["network"]="/etc/systemd/network"
    ["zram"]="/etc/systemd"
    ["iwd"]="/etc/iwd"
    ["dhcpcd"]="/etc"
    ["git"]="$HOME/.config/git"
    ["sway"]="$HOME/.config/sway"
    ["rofi"]="$HOME/.config/rofi"
    ["mpd"]="$HOME/.config/mpd"
    ["ncmpcpp"]="$HOME/.config/ncmpcpp"
    ["kitty"]="$HOME/.config/kitty"
    ["waybar"]="$HOME/.config/waybar"
    ["gtk3"]="$HOME/.config/gtk-3.0"
    ["gtk4"]="$HOME/.config/gtk-4.0"
    ["mako"]="$HOME/.config/mako"
    ["swayidle"]="$HOME/.config/swayidle"
    ["mpv"]="$HOME/.config/mpv"
    ["systemd"]="$HOME/.config/systemd"
    ["lf"]="$HOME/.config/lf"
    ["helix"]="$HOME/.config/helix"
    ["nvim"]="$HOME/.config/nvim"
    ["xfce4"]="$HOME/.config/xfce4"
    ["prettierd"]="$HOME/.config/prettierd"
    ["kanata"]="$HOME/.config/kanata"
    ["tmux"]="$HOME/.config/tmux"
    ["zellij"]="$HOME/.config/zellij"
    ["qutebrowser"]="$HOME/.config/qutebrowser"
    ["zathura"]="$HOME/.config/zathura"
)

# Store setup scripts to run after stowing
declare -a SETUP_SCRIPTS=()

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

# Function to unstow all packages
unstow_all_packages() {
    log "info" "Unstowing all packages before stowing again"
    
    # Get list of packages (directories in STOW_DIR)
    local packages=()
    while IFS= read -r -d '' pkg; do
        packages+=($(basename "$pkg"))
    done < <(find "$STOW_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
    
    # Process each package
    for package in "${packages[@]}"; do
        # Determine target directory based on package name
        local target_dirs=""
        local use_sudo="false"
        for prefix in "${!TARGET_DIRS[@]}"; do
            # Check if package matches any prefix in the comma-separated list
            IFS=',' read -ra prefixes <<< "$prefix"
            for p in "${prefixes[@]}"; do
                if [[ "$package" == "$(echo "$p" | xargs)" ]]; then
                    target_dirs="${TARGET_DIRS[$prefix]}"
                    break 2
                fi
            done
        done

        if [[ -z "$target_dirs" ]]; then
            continue
        fi

        local package_dir="$STOW_DIR/$package"

        # Process each target directory
        for target_dir in $target_dirs; do
            # Ensure $HOME is expanded to absolute path
            target_dir="${target_dir/#\$HOME/$HOME}"

            # Check if this is a system directory that requires sudo
            if [[ "$target_dir" == "/etc"* ]]; then
                use_sudo="true"
                check_sudo
                request_sudo
            fi

            # Find all files in the package
            while IFS= read -r -d '' file; do
                # Skip setup.sh files
                if [[ "$(basename "$file")" == "setup.sh" ]]; then
                    continue
                fi
                
                # Get the relative path from the package directory
                local rel_path="${file#$package_dir/}"
                local target_file="$target_dir/$rel_path"
                
                # Check if the target is a symlink pointing to our stow dir
                if [[ -L "$target_file" ]]; then
                    local link_target=$(readlink "$target_file")
                    if [[ "$link_target" == "$file" || "$link_target" == "$STOW_DIR"* ]]; then
                        log "info" "Removing symlink: $target_file"
                        if [[ "$use_sudo" == "true" ]]; then
                            sudo rm "$target_file"
                        else
                            rm "$target_file"
                        fi
                    fi
                fi
            done < <(find "$package_dir" -type f -print0)

            # Clean up empty directories
            if [[ -d "$target_dir" ]]; then
                log "info" "Cleaning up empty directories in $target_dir"
                if [[ "$use_sudo" == "true" ]]; then
                    sudo find "$target_dir" -type d -empty -delete 2>/dev/null || true
                else
                    find "$target_dir" -type d -empty -delete 2>/dev/null || true
                fi
            fi
        done
    done
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

    # Check for setup.sh and add to the list if found
    local setup_script="$package_dir/setup.sh"
    if [[ -f "$setup_script" && -x "$setup_script" ]]; then
        log "info" "Found setup script: $setup_script"
        SETUP_SCRIPTS+=("$setup_script")
    fi

    # Determine target directory based on package name
    local target_dirs=""
    local use_sudo="false"
    for prefix in "${!TARGET_DIRS[@]}"; do
        # Check if package matches any prefix in the comma-separated list
        IFS=',' read -ra prefixes <<< "$prefix"
        for p in "${prefixes[@]}"; do
            if [[ "$package" == "$(echo "$p" | xargs)" ]]; then
                target_dirs="${TARGET_DIRS[$prefix]}"
                break 2
            fi
        done
    done

    if [[ -z "$target_dirs" ]]; then
        log "info" "No target directory mapping found for package $package, skipping"
        return
    fi

    # Process each target directory
    for target_dir in $target_dirs; do
        # Ensure $HOME is expanded to absolute path
        target_dir="${target_dir/#\$HOME/$HOME}"

        # Check if this is a system directory that requires sudo
        if [[ "$target_dir" == "/etc"* ]]; then
            use_sudo="true"
            check_sudo
            request_sudo
        fi

        log "info" "Processing target directory: $target_dir"

        # Make sure target directory exists
        if [[ ! -d "$target_dir" ]]; then
            log "info" "Target directory $target_dir does not exist, creating it"
            if [[ "$use_sudo" == "true" ]]; then
                sudo mkdir -p "$target_dir"
            else
                mkdir -p "$target_dir"
            fi
        fi

        # Find all files (not directories) in the package, including in nested folders
        while IFS= read -r -d '' file; do
            # Skip setup.sh files
            if [[ "$(basename "$file")" == "setup.sh" ]]; then
                continue
            fi
            
            # Get the relative path from the package directory
            local rel_path="${file#$package_dir/}"
            local target_file="$target_dir/$rel_path"
            local target_dir_path="$(dirname "$target_file")"

            # Create the target directory if it doesn't exist
            if [[ ! -d "$target_dir_path" ]]; then
                log "info" "Creating directory: $target_dir_path"
                if [[ "$use_sudo" == "true" ]]; then
                    sudo mkdir -p "$target_dir_path"
                else
                    mkdir -p "$target_dir_path"
                fi
            fi

            # Backup existing file if it exists and is not a symlink
            if [[ -e "$target_file" && ! -L "$target_file" ]]; then
                backup_item "$target_file" "$target_file" "$use_sudo"
            # Remove existing symlink if it exists
            elif [[ -L "$target_file" ]]; then
                log "info" "Removing existing symlink: $target_file"
                if [[ "$use_sudo" == "true" ]]; then
                    sudo rm "$target_file"
                else
                    rm "$target_file"
                fi
            fi

            # Create symlink
            log "info" "Creating symlink: $file -> $target_file"
            if [[ "$use_sudo" == "true" ]]; then
                sudo ln -sf "$file" "$target_file"
            else
                ln -sf "$file" "$target_file"
            fi
        done < <(find "$package_dir" -type f -print0)
    done
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

# Run setup scripts
run_setup_scripts() {
    if [ ${#SETUP_SCRIPTS[@]} -eq 0 ]; then
        log "info" "No setup scripts to run"
        return
    fi
    
    log "info" "Running setup scripts..."
    
    for script in "${SETUP_SCRIPTS[@]}"; do
        log "info" "Executing setup script: $script"
        if ! "$script"; then
            log "error" "Setup script failed: $script"
        else
            log "success" "Setup script completed: $script"
        fi
    done
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

    # Reset the setup scripts array
    SETUP_SCRIPTS=()

    # First unstow all packages
    unstow_all_packages

    # Process each package
    for package in "$STOW_DIR"/*; do
        if [[ -d "$package" ]]; then
            process_package "$(basename "$package")"
        fi
    done

    # Run all collected setup scripts after stowing
    run_setup_scripts

    log "success" "Backup and stow process completed successfully"
}

# Run the main function
main
