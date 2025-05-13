#!/bin/bash

pacman_pkgs=(
  lsd
  fzf
  zsh
  zsh-completions
  bat
  zoxide
  findutils
)

GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
  echo "Failed to source gloabl.sh"
  exit 1
fi

printf "\n%s - Installing ${SKY_BLUE}zsh packages${RESET} .... \n" "${NOTE}"
install_package_pacman_all "${pacman_pkgs[@]}"

if command -v zsh >/dev/null; then
  printf "${NOTE} Installing ${SKY_BLUE}Oh My Zsh and plugins${RESET} ...\n"

  if [ ! -d "$HOME/.config/oh-my-zsh" ]; then  
    ZSH="$HOME/.config/oh-my-zsh" sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended --keep-zshrc
  else
    echo "${INFO} Directory .config/oh-my-zsh already exists. Skipping re-installation." >&2
  fi
  
  if [ ! -d "$HOME/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  else
    echo "${INFO} Directory zsh-autosuggestions already exists. Cloning Skipped." >&2
  fi

  if [ ! -d "$HOME/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  else
    echo "${INFO} Directory zsh-syntax-highlighting already exists. Cloning Skipped." >&2
  fi

  echo "${INFO} This script simply installs, it doesn't modify nor backup .zshrc and it doesn't change the default shell." >&2
fi

printf "\n%.0s" {1..1}
