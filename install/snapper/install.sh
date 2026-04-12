#!/bin/bash
set -e

snapper_packages=(
  snapper
)

timeshift_packages=(
  timeshift
)

GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  echo "[ERROR] Failed to source global.sh"
  exit 1
fi

log "info" "Installing snapper packages"
install_packages_pacman "${snapper_packages[@]}" || exit 1

if ! command -v snapper &>/dev/null; then
  log "error" "snapper installation failed"
  exit 1
fi

log "info" "Removing timeshift and related packages"
for pkg in "${timeshift_packages[@]}"; do
  if is_installed "$pkg"; then
    log "info" "Removing $pkg"
    sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || true
  fi
done

log "info" "Removing timeshift user configuration"
rm -rf "$HOME/.timeshift" 2>/dev/null || true
sudo rm -f /etc/timeshift.json 2>/dev/null || true

log "info" "Removing timeshift systemd timers"
sudo systemctl stop timeshift-boot.timer timeshift-weekly.timer 2>/dev/null || true
sudo systemctl disable timeshift-boot.timer timeshift-weekly.timer 2>/dev/null || true

log "success" "Snapper installation completed"
log "info" "Now run: ./stow.sh --username shad"
log "info" "Then run: sudo ./packages/snapper-config/setup.sh"
