#!/bin/bash

echo "Setting up systemd user services..."

# Enable and start the polkit agent service
systemctl --user enable --now polkit-agent.service

echo "Systemd setup completed successfully."
