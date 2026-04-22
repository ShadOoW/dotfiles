#!/bin/bash

chmod +x /etc/ly/login.sh
sed -i 's|^login_cmd = .*|login_cmd = /etc/ly/login.sh|' /etc/ly/config.ini
mkdir -p /usr/share/xsessions

echo "ly configured."
