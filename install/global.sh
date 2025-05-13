#!/bin/bash
set -e

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Function to install packages with pacman
install_package_pacman() {
    if pacman -Q "$1" &>/dev/null ; then
        echo -e "${INFO} ${MAGENTA}$1${RESET} is already installed. Skipping..."
    else
        sudo pacman -S --noconfirm "$1"

        if pacman -Q "$1" &>/dev/null ; then
            echo -e "${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
        else
            echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install."
        fi
    fi
}

install_package_pacman_all() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
      echo -e "${INFO} ${MAGENTA}$pkg${RESET} is already installed. Skipping..."
    else
      to_install+=("$pkg")
    fi
  done

  if [ "${#to_install[@]}" -gt 0 ]; then
    echo -e "${NOTE} Installing packages: ${YELLOW}${to_install[*]}${RESET}"
    sudo pacman -S --noconfirm "${to_install[@]}" || {
      echo -e "${ERROR} Failed to install some base packages"
      exit 1
    }
    echo -e "${OK} All requested packages installed successfully!"
  else
    echo -e "${INFO} All base packages are already installed."
  fi
}

ISAUR=$(command -v yay || command -v paru)

# Function to install packages with yay/paru
install_package() {
    if $ISAUR -Q "$1" &>/dev/null ; then
        echo -e "${INFO} ${MAGENTA}$1${RESET} is already installed. Skipping..."
    else
        $ISAUR -S --noconfirm "$1"

        if $ISAUR -Q "$1" &>/dev/null ; then
            echo -e "${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
        else
            echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install :("
        fi
    fi
}

# Force install without check
install_package_f() {
    $ISAUR -S --noconfirm "$1" &
    show_progress $! "$1"

    if $ISAUR -Q "$1" &>/dev/null ; then
        echo -e "${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
    else
        echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install :("
    fi
}

# Uninstall a package
uninstall_package() {
    local pkg="$1"

    if pacman -Qi "$pkg" &>/dev/null; then
        echo -e "${NOTE} removing $pkg ..."
        sudo pacman -R --noconfirm "$pkg" 2>&1 | grep -v "error: target not found"

        if ! pacman -Qi "$pkg" &>/dev/null; then
            echo -e "\e[1A\e[K${OK} $pkg removed."
        else
            echo -e "\e[1A\e[K${ERROR} $pkg Removal failed. No actions required."
            return 1
        fi
    else
        echo -e "${INFO} Package $pkg not installed, skipping."
    fi
    return 0
}
