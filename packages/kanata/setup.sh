#!/bin/bash
set -e

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Create uinput group if it doesn't exist
create_uinput_group() {
    if ! getent group uinput > /dev/null; then
        log "info" "Creating uinput group"
        if sudo groupadd uinput; then
            log "success" "Created uinput group"
        else
            log "error" "Failed to create uinput group"
            return 1
        fi
    else
        log "info" "uinput group already exists"
    fi
    return 0
}

# Add user to a group
add_user_to_group() {
    local group="$1"
    local user=${SUDO_USER:-$USER}

    if ! groups "$user" | grep -q "\b$group\b"; then
        log "info" "Adding user ${C_ACCENT}$user${RESET} to group ${C_ACCENT}$group${RESET}"
        if sudo usermod -aG "$group" "$user"; then
            log "success" "Added user ${C_ACCENT}$user${RESET} to group ${C_ACCENT}$group${RESET}"
        else
            log "error" "Failed to add user ${C_ACCENT}$user${RESET} to group ${C_ACCENT}$group${RESET}"
            return 1
        fi
    else
        log "info" "User ${C_ACCENT}$user${RESET} is already in group ${C_ACCENT}$group${RESET}"
    fi
    return 0
}

# Setup udev rules for uinput
setup_udev_rules() {
    local udev_rule_file="/etc/udev/rules.d/99-uinput.rules"
    local rule_content='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'

    log "info" "Setting up udev rules for uinput"
    
    if [[ -f "$udev_rule_file" ]] && grep -q "$rule_content" "$udev_rule_file"; then
        log "info" "udev rules for uinput already exist"
        return 0
    fi

    echo "$rule_content" | sudo tee "$udev_rule_file" > /dev/null
    
    if [[ $? -eq 0 ]]; then
        log "success" "Added udev rules for uinput"
        
        log "info" "Reloading udev rules"
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        
        log "success" "udev rules reloaded"
    else
        log "error" "Failed to add udev rules for uinput"
        return 1
    fi
    
    return 0
}

# Configure uinput module to be loaded at boot
setup_uinput_module() {
    local modules_file="/etc/modules-load.d/uinput.conf"
    
    log "info" "Configuring uinput module to load at boot"
    
    # Check if module is already configured to load at boot
    if [[ -f "$modules_file" ]] && grep -q "uinput" "$modules_file"; then
        log "info" "uinput module is already configured to load at boot"
    else
        # Create the modules-load.d file
        echo "uinput" | sudo tee "$modules_file" > /dev/null
        if [[ $? -eq 0 ]]; then
            log "success" "Configured uinput module to load at boot"
        else
            log "error" "Failed to configure uinput module loading"
            return 1
        fi
    fi
    
    # Load the module immediately if not already loaded
    if ! lsmod | grep -q "uinput"; then
        log "info" "Loading uinput module now"
        if sudo modprobe uinput; then
            log "success" "Loaded uinput module"
        else
            log "error" "Failed to load uinput module"
            return 1
        fi
    else
        log "info" "uinput module is already loaded"
    fi
    
    return 0
}

# Main function
main() {
    log "info" "${ICON_PACKAGE} Setting up kanata..."
    
    # Create uinput group if needed
    create_uinput_group
    
    # Add user to necessary groups
    add_user_to_group "input"
    add_user_to_group "uinput"
    
    # Setup udev rules
    setup_udev_rules
    
    # Configure uinput module loading
    setup_uinput_module
    
    log "success" "Kanata setup completed successfully!"
    log "warning" "You may need to log out and log back in for group changes to take effect."
}

# Run the main function
main 
