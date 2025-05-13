#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Thunar #

pacman_pkgs=(
  thunar
  thunar-volman
  tumbler
  ffmpegthumbnailer
  thunar-archive-plugin
  xarchiver
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."

GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
  echo "Failed to source gloabl.sh"
  exit 1
fi

echo -e "${INFO} Installing ${SKY_BLUE}Thunar${RESET} Packages..."
install_package_pacman_all "${pacman_pkgs[@]}"
