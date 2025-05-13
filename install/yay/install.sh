#!/bin/bash
set -e

pkg="yay-bin"

# Source the global functions script
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../global.sh"
if ! source "$GLOBAL_SH"; then
  echo "Failed to source gloabl.sh"
  exit 1
fi

if command -v yay >/dev/null 2>&1; then
  echo "[INFO] yay is already installed. Skipping installation."
  exit 0
fi

# Remove existing directory if it exists
if [ -d "$pkg" ]; then
    echo "${NOTE} Removing existing directory $pkg"
    rm -rf "$pkg"
fi

# Clone the AUR repo
echo "${NOTE} Cloning ${YELLOW}$pkg${RESET} from AUR..."
git clone "https://aur.archlinux.org/$pkg.git" || {
    echo "${ERROR} Failed to clone ${YELLOW}$pkg${RESET} from AUR"
    exit 1
}

# Enter directory and build package
cd "$pkg" || {
    echo "${ERROR} Failed to enter ${YELLOW}$pkg${RESET} directory"
    exit 1
}

echo "${NOTE} Building and installing ${YELLOW}$pkg${RESET}..."
makepkg -si --noconfirm || {
    echo "${ERROR} Failed to install ${YELLOW}$pkg${RESET}"
    exit 1
}

cd ..

if [ -d "$pkg" ]; then
    echo "${NOTE} Removing existing directory $pkg"
    rm -rf "$pkg"
fi

echo -e "\n${NOTE} Performing full system update..."
ISAUR=$(command -v yay)

if [ -z "$ISAUR" ]; then
    echo "${ERROR} No AUR helper (yay/paru) found after installation."
    exit 1
fi

$ISAUR -Syu --noconfirm || {
    echo "${ERROR} System update failed"
    exit 1
}

echo -e "\n${OK} System updated successfully."