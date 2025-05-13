pacman_nvidia=(
  nvidia-dkms
  nvidia-settings
  nvidia-utils
  libva
  libva-nvidia-driver
)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.." || { echo "[ERROR] Failed to change directory."; exit 1; }

# Source global functions
if ! source "$(dirname "$(readlink -f "$0")")/global.sh"; then
  echo "[ERROR] Failed to source global.sh"
  exit 1
fi

echo "[INFO] Installing Nvidia packages and Linux headers..."
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
  for pkg in "${krnl}-headers" "${nvidia_pkg[@]}"; do
    install_package "$pkg"
  done
done

echo "[INFO] Checking mkinitcpio.conf for Nvidia modules..."
if ! grep -qE '^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
  sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
  echo "[OK] Nvidia modules added to mkinitcpio.conf"
else
  echo "[NOTE] Nvidia modules already present in mkinitcpio.conf"
fi

echo "[INFO] Rebuilding initramfs with mkinitcpio..."
sudo mkinitcpio -P

CONF_FILE="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$CONF_FILE" ]; then
  echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$CONF_FILE"
  echo "[OK] Nvidia modprobe options added"
else
  echo "[INFO] Nvidia modprobe config already exists"
fi

if [ -f /etc/default/grub ]; then
  echo "[INFO] GRUB detected. Updating boot options..."
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
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo "[OK] GRUB config updated"
  else
    echo "[NOTE] GRUB already configured for Nvidia"
  fi
fi

if [ -f /boot/loader/loader.conf ]; then
  echo "[INFO] systemd-boot detected. Configuring entries..."
  for conf in /boot/loader/entries/*.conf; do
    [ -f "$conf" ] || continue
    sudo cp "$conf" "$conf.bak"
    opts=$(grep "^options" "$conf" | sed 's/ nvidia-drm.modeset=1//g; s/ nvidia_drm.fbdev=1//g')
    sudo sed -i "/^options/c\\$opts nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$conf"
    echo "[OK] Updated $conf with Nvidia boot options"
  done
fi

echo -e "\n[INFO] Nvidia setup complete.\n"
