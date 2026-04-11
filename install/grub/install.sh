#!/bin/bash
set -e

# Theme configuration
THEME_NAME="arch-linux"
GRUB_DIR="/boot/grub"
GRUB_CFG="/etc/default/grub"
THEME_DEST="$GRUB_DIR/themes/$THEME_NAME"

# Repository information
REPO_NAME="distro-grub-themes"
REPO_URL="https://github.com/AdisonCavani/${REPO_NAME}.git"
CLONE_DIR="/tmp/${REPO_NAME}"

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  log "error" "Failed to source global.sh"
  exit 1
fi

log "info" "Installing GRUB theme: ${C_ACCENT}$THEME_NAME${RESET}"

# Clone theme repository
if [ ! -d "$CLONE_DIR" ]; then
  log "info" "Cloning theme repository"
  if ! git clone "$REPO_URL" "$CLONE_DIR"; then
    log "error" "Failed to clone theme repository"
    exit 1
  fi
else
  log "info" "Theme repository already exists"
fi

# Create GRUB theme directory
if [ ! -d "$GRUB_DIR/themes" ]; then
  log "info" "Creating GRUB theme directory"
  if ! sudo mkdir -p "$GRUB_DIR/themes"; then
    log "error" "Failed to create GRUB theme directory"
    exit 1
  fi
fi

# Install theme
THEME_TAR="$CLONE_DIR/themes/$THEME_NAME.tar"
if [ -f "$THEME_TAR" ]; then
  log "info" "Installing theme files"
  if ! sudo mkdir -p "$THEME_DEST" || ! sudo tar -C "$THEME_DEST" -xf "$THEME_TAR"; then
    log "error" "Failed to install theme files"
    exit 1
  fi
else
  log "error" "Theme archive not found: $THEME_TAR"
  exit 1
fi

# Cleanup repository
if [ -d "$CLONE_DIR" ]; then
  log "info" "Cleaning up theme repository"
  rm -rf "$CLONE_DIR"
fi

# Configure GRUB
log "info" "Configuring GRUB settings"

# Remove existing settings
sudo sed -i '/^GRUB_THEME=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_SAVEDEFAULT=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_DEFAULT=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_TIMEOUT=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_GFXMODE=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_PRELOAD_MODULES=/d' "$GRUB_CFG"

# Add i915 parameters for Intel GPU Wayland support
log "info" "Adding i915 kernel parameters for Intel GPU"
if grep -q 'i915.enable_psr=0' "$GRUB_CFG"; then
  log "info" "i915 parameters already present, skipping"
else
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 i915.enable_psr=0 i915.enable_fbc=0"/' "$GRUB_CFG"
  log "info" "i915 parameters added to GRUB_CMDLINE_LINUX_DEFAULT"
fi

# Add new settings
{
  echo "GRUB_THEME=\"$GRUB_DIR/themes/$THEME_NAME/theme.txt\""
  echo "GRUB_DEFAULT=saved"
  echo "GRUB_SAVEDEFAULT=true"
  echo "GRUB_TIMEOUT=15"
  echo "GRUB_GFXMODE=1920x1080x32,auto"
  echo "GRUB_PRELOAD_MODULES=\"part_gpt part_msdos efi_gop all_video\""
} | sudo tee -a "$GRUB_CFG" >/dev/null

# Update GRUB configuration
log "info" "Updating GRUB configuration"
if ! sudo grub-mkconfig -o "$GRUB_DIR/grub.cfg"; then
  log "error" "Failed to update GRUB configuration"
  exit 1
fi

log "success" "GRUB theme installation completed"
