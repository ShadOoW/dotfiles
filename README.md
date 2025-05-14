# Dotfiles Management System

This repository contains my personal dotfiles and system configurations, managed using GNU Stow. The deployment script (`deploy.sh`) automatically backs up existing configurations and creates symbolic links for the new ones.

## Package Overview

### ZSH Configuration (`zsh`)
- Target Directory: `$HOME`
- Contains ZSH shell configuration files
- Includes custom aliases, functions, and shell settings

### Browser Configuration (`browsers`)
- Target Directory: `$HOME/.config`
- Contains browser-specific configurations needed for hyprland
- Manages browser profiles and settings

### Network Configuration (`network`)
- Target Directory: `/etc/systemd/network`
- Contains systemd-networkd configuration files
- Requires root permissions for deployment

#### Finding Network Interface Names

To properly configure network interfaces, you'll need to know their names. Here's how to find them:

1. List all network interfaces:
```bash
ip link show
```

2. Identify wireless interfaces:
   - Wireless interfaces typically start with `wlan` or `wlp`
   - Example output: `wlan0` or `wlp3s0`

3. Identify USB tethering interfaces:
   - Connect your USB device
   - Run `ip link show` again
   - New interface will appear, typically named:
     - `usb0` or
     - `enp0s20f0u1` (or similar pattern)
   - The interface will appear when you enable tethering on your device

### iwd
- systemctl enable/start iwd.service
restart after stow
- systemctl restart iwd.service

### UDEV Rules (`udev`)
- Target Directory: `/etc/udev/rules.d`
- Contains custom udev rules for device management
- Requires root permissions for deployment

#### Setting Up UDEV Rules

To create a new udev rule for a device:

1. Find the vendor and product ID:
```bash
lsusb
```
Example output:
```
Bus 002 Device 001: ID 1234:5678 Vendor Name Device Name
```
The format is `ID vendor_id:product_id`

2. Create your udev rule in the `udev` package directory

3. After adding or modifying rules:
```bash
# Reload udev rules
sudo udevadm control --reload-rules

# Trigger the rules
sudo udevadm trigger
```

## Installation

1. Clone this repository:
```bash
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
```

2. Run the deployment script:
```bash
./deploy.sh
```

## SSH Key Setup for GitHub

To generate an SSH key for GitHub authentication:

1. Generate a new SSH key:
```bash
ssh-keygen -t ed25519 -C "shadoow.ma@gmail.com" -f ~/.ssh/id_github
```

2. Start the SSH agent:
```bash
eval "$(ssh-agent -s)"
```

3. Add the key to SSH agent:
```bash
ssh-add ~/.ssh/id_github
```

4. Copy the public key to add to GitHub:
```bash
cat ~/.ssh/id_github.pub
```

5. Add the public key to your GitHub account:
   - Go to GitHub → Settings → SSH and GPG keys
   - Click "New SSH key"
   - Paste your public key and save

6. Test your connection:
```bash
ssh -T git@github.com
```

The script will:
- Back up existing configurations
- Create symbolic links using stow
- Handle system-level configurations with proper permissions
- Run the authentification agent and manage the github ssh key
