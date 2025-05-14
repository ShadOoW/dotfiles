#!/bin/bash
set -e

# Nvidia packages
pacman_packages=(
    nvidia-dkms
    nvidia-settings
    nvidia-utils
    libva
    libva-nvidia-driver
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
    log "error" "Failed to source global.sh"
    exit 1
fi

# Install Nvidia packages and kernel headers
log "info" "Installing Nvidia packages and Linux headers"
for kernel in $(cat /usr/lib/modules/*/pkgbase); do
    # Install kernel headers
    install_package_pacman "${kernel}-headers" || exit 1
done

# Install Nvidia packages
install_packages_pacman "${pacman_packages[@]}" || exit 1

# Configure mkinitcpio
log "info" "Configuring mkinitcpio for Nvidia modules"
if ! grep -qE '^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    log "success" "Nvidia modules added to mkinitcpio.conf"
else
    log "info" "Nvidia modules already present in mkinitcpio.conf"
fi

# Rebuild initramfs
log "info" "Rebuilding initramfs"
if ! sudo mkinitcpio -P; then
    log "error" "Failed to rebuild initramfs"
    exit 1
fi

# Configure modprobe
CONF_FILE="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$CONF_FILE" ]; then
    log "info" "Creating Nvidia modprobe configuration"
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$CONF_FILE" >/dev/null
    log "success" "Nvidia modprobe options added"
else
    log "info" "Nvidia modprobe config already exists"
fi

# Configure bootloader
if [ -f /etc/default/grub ]; then
    log "info" "Configuring GRUB for Nvidia"
    updated=0
    
    if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        updated=1
    fi
    
    if ! grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
        updated=1
    fi
    
    if [ "$updated" -eq 1 ]; then
        log "info" "Updating GRUB configuration"
        if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            log "error" "Failed to update GRUB config"
            exit 1
        fi
        log "success" "GRUB config updated"
    else
        log "info" "GRUB already configured for Nvidia"
    fi
fi

# Configure systemd-boot if present
if [ -f /boot/loader/loader.conf ]; then
    log "info" "Configuring systemd-boot for Nvidia"
    for conf in /boot/loader/entries/*.conf; do
        [ -f "$conf" ] || continue
        
        # Backup original config
        sudo cp "$conf" "$conf.bak"
        
        # Update boot options
        opts=$(grep "^options" "$conf" | sed 's/ nvidia-drm.modeset=1//g; s/ nvidia_drm.fbdev=1//g')
        if ! sudo sed -i "/^options/c\\$opts nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$conf"; then
            log "error" "Failed to update $conf"
            exit 1
        fi
        log "success" "Updated $conf with Nvidia boot options"
    done
fi

log "success" "Nvidia setup completed successfully"
