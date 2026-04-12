#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo "[snapper-setup] $*"
}

log "Setting up snapper..."

if ! command -v snapper &>/dev/null; then
  log "ERROR: snapper is not installed"
  exit 1
fi

CONFIG_SOURCE="$SCRIPT_DIR/root"
CONFIG_TARGET="/etc/snapper/configs/root"

log "Installing snapper config"

if [ -L "$CONFIG_TARGET" ]; then
  log "Removing stow symlink"
  sudo rm "$CONFIG_TARGET"
elif [ -f "$CONFIG_TARGET" ]; then
  log "Backing up existing config"
  sudo cp "$CONFIG_TARGET" "$CONFIG_TARGET.bak"
fi

sudo cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
log "Config installed to $CONFIG_TARGET"

log "Creating initial snapshot"
sudo snapper --config root create --description "initial-setup" --cleanup-algorithm number || true

log "Enabling snapper-cleanup.timer"
sudo systemctl enable --now snapper-cleanup.timer 2>/dev/null || true

log "Snapper setup complete!"
log ""
log "Config location: $CONFIG_TARGET"
log "Usage:"
log "  snapper list               - List snapshots"
log "  snapper list | grep number - List numbered snapshots (updates)"
log "  sudo snapper delete <n>    - Delete snapshot by number"
log ""
log "To boot into a snapshot:"
log "  1. Reboot, select 'Arch Linux' GRUB entry"
log "  2. From GRUB, go to 'Arch Linux snapshots' submenu"
log "  3. Select the snapshot you want to test"
log "  4. After testing, if good: sudo snapper rollback"
log "  5. If bad: reboot and select original entry, then sudo snapper rollback"
