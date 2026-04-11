#!/bin/bash

# Make the login script executable
chmod +x /etc/ly/login.sh

# Point ly's login_cmd at our script (idempotent)
sudo sed -i 's|^login_cmd = .*|login_cmd = /etc/ly/login.sh|' /etc/ly/config.ini

# Ensure X11 sessions directory exists (ly errors if missing even on Wayland-only setups)
sudo mkdir -p /usr/share/xsessions

echo "ly setup complete."
