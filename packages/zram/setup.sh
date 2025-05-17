#!/bin/bash
set -e

echo "Setting up zram configuration..."

# Enable zram module
echo "zram" | sudo tee /etc/modules-load.d/zram.conf

# Reload systemd configuration
echo "Reloading systemd daemon..."
sudo systemctl daemon-reexec

# Check zram device status
echo "Checking zram device status..."
systemctl status /dev/zram0 || true

# Manual instructions
echo -e "\n\033[1mMANUAL CONFIGURATION STEPS:\033[0m"
echo -e "\033[33m1. Ensure your swap partition is listed like this (with lower priority):\033[0m"
echo "   UUID=xxxxxx none swap defaults,pri=10 0 0"
echo ""
echo -e "\033[33m2. Disable zswap by following these steps:\033[0m"
echo "   a. Edit GRUB configuration:"
echo "      sudo nano /etc/default/grub"
echo "   b. Add zswap.enabled=0 to GRUB_CMDLINE_LINUX_DEFAULT:"
echo "      GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet zswap.enabled=0\""
echo "   c. Update GRUB configuration:"
echo "      sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo "   d. Reboot your system to apply changes"
echo ""
echo -e "\033[32mZRAM setup complete!\033[0m"
