#!/bin/bash

THEME_NAME="arch-linux"
GRUB_DIR="/boot/grub"
REPO_NAME="distro-grub-themes"
REPO_URL="https://github.com/AdisonCavani/${REPO_NAME}.git"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLONE_DIR="$SCRIPT_DIR/$REPO_NAME"
THEME_DEST="$GRUB_DIR/themes/$THEME_NAME"

echo -e "${INFO} Using theme: ${MAGENTA}$THEME_NAME${RESET}"
echo -e "${INFO} GRUB directory: ${MAGENTA}$GRUB_DIR${RESET}"

if [ ! -d "$CLONE_DIR" ]; then
  echo -e "${INFO} Cloning $REPO_URL..."
  git clone "$REPO_URL" "$CLONE_DIR" || { echo "${ERROR} Failed to clone theme repo"; exit 1; }
else
  echo -e "${INFO} Repo already exists. Skipping clone."
fi

if [ ! -d "$GRUB_DIR/themes" ]; then
  echo -e "${INFO} Creating GRUB theme directory..."
  sudo mkdir -p "$GRUB_DIR/themes"
fi

THEME_TAR="$CLONE_DIR/themes/$THEME_NAME.tar"
if [ -f "$THEME_TAR" ]; then
  echo -e "${INFO} Installing theme: $THEME_NAME..."
  sudo mkdir -p "$THEME_DEST"
  sudo tar -C "$GRUB_DIR/themes/$THEME_NAME" -xf "$THEME_TAR"
else
  echo "${ERROR} Theme archive $THEME_TAR not found."
  exit 1
fi

if [ -d "$CLONE_DIR" ]; then
    echo "${NOTE} Removing existing directory $CLONE_DIR"
    rm -rf "$CLONE_DIR"
fi

GRUB_CFG="/etc/default/grub"

echo -e "${INFO} Configuring GRUB settings..."

sudo sed -i '/^GRUB_THEME=/d' "$GRUB_CFG"
echo "GRUB_THEME=\"$GRUB_DIR/themes/$THEME_NAME/theme.txt\"" | sudo tee -a "$GRUB_CFG" > /dev/null

sudo sed -i '/^GRUB_SAVEDEFAULT=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_DEFAULT=/d' "$GRUB_CFG"
sudo sed -i '/^GRUB_TIMEOUT=/d' "$GRUB_CFG"

echo "GRUB_DEFAULT=saved" | sudo tee -a "$GRUB_CFG" > /dev/null
echo "GRUB_SAVEDEFAULT=true" | sudo tee -a "$GRUB_CFG" > /dev/null
echo "GRUB_TIMEOUT=15" | sudo tee -a "$GRUB_CFG" > /dev/null

echo -e "${INFO} Updating GRUB config..."
sudo grub-mkconfig -o "$GRUB_DIR/grub.cfg"

echo -e "${OK} GRUB theme \"$THEME_NAME\" installed and configured!"
