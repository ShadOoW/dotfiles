#!/bin/bash

# Make the login script executable
chmod +x /etc/ly/login.sh

# Point ly's login_cmd at our script (idempotent)
sudo sed -i 's|^login_cmd = .*|login_cmd = /etc/ly/login.sh|' /etc/ly/config.ini

echo "ly setup complete."
