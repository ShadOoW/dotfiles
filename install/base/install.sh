#!/bin/bash

pacman_pkg=(
  base-devel
  stow
  iwd
  debugedit
  git
  fakeroot
  archlinux-keyring
  zip
  unzip
)

blue_pkg=(
  bluez
  bluez-utils
  blueman
)

pacman_fonts=(
  adobe-source-code-pro-fonts 
  noto-fonts-emoji
  otf-font-awesome 
  ttf-droid 
  ttf-fira-code
  ttf-fantasque-nerd
  ttf-jetbrains-mono 
  ttf-jetbrains-mono-nerd
  noto-fonts
)

GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
  echo "Failed to source gloabl.sh"
  exit 1
fi

printf "\n%s - Installing ${SKY_BLUE}base packages${RESET} .... \n" "${NOTE}"
install_package_pacman_all "${pacman_pkg[@]}"

printf "\n%s - Installing ${SKY_BLUE}bluethooth packages${RESET} .... \n" "${NOTE}"
install_package_pacman_all "${blue_pkg[@]}"

printf " Activating ${YELLOW}Bluetooth${RESET} Services...\n"
sudo systemctl enable --now bluetooth.service

printf "\n%s - Installing ${SKY_BLUE}fonts${RESET} .... \n" "${NOTE}"
install_package_pacman_all "${pacman_fonts[@]}"
