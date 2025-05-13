#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.." || { echo "[ERROR] Failed to change directory"; exit 1; }

# Source global helper functions
if ! source "$(dirname "$(readlink -f "$0")")/global.sh"; then
  echo "[ERROR] Failed to source global.sh"
  exit 1
fi

pacman_conf="/etc/pacman.conf"

echo -e "${NOTE} Enhancing ${MAGENTA}pacman.conf${RESET} with extra settings..."

# 1. Uncomment useful pacman features
features=(
  "Color"
  "CheckSpace"
  "VerbosePkgLists"
  "ParallelDownloads"
)

for feature in "${features[@]}"; do
  if grep -q "^#$feature" "$pacman_conf"; then
    sudo sed -i "s/^#$feature/$feature/" "$pacman_conf"
    echo -e "${INFO} Enabled: ${YELLOW}$feature${RESET}"
  else
    echo -e "${INFO} ${YELLOW}$feature${RESET} is already enabled"
  fi
done

if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
  sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
  echo -e "${INFO} Added ${MAGENTA}ILoveCandy${RESET} to pacman.conf"
else
  echo -e "${NOTE} ${YELLOW}ILoveCandy${RESET} already present. Skipping."
fi

if grep -q "^\[multilib\]" "$pacman_conf"; then
  echo -e "${INFO} ${MAGENTA}Multilib${RESET} is already enabled."
else
  echo -e "${INFO} Enabling ${MAGENTA}multilib${RESET} repository..."
  sudo sed -i '/#\[multilib\]/,+1 s/^#//' "$pacman_conf"
fi

if ! command -v reflector &> /dev/null; then
  echo -e "${NOTE} Installing ${YELLOW}reflector${RESET}..."
  sudo pacman -S --noconfirm reflector
fi

echo -e "${INFO} Optimizing mirrorlist using reflector..."
sudo reflector --country "$(curl -s https://ipapi.co/country/)" \
  --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# 5. Sync updated pacman repositories
echo -e "\n${INFO} Synchronizing Pacman repositories..."
sudo pacman -Sy

echo -e "\n${OK} Pacman configuration and optimization complete.\n"
