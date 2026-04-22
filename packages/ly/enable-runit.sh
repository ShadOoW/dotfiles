#!/bin/bash

rm -f /var/service/ly
rm -f /var/service/agetty-tty2
ln -sf /etc/sv/ly /var/service/ly

echo "ly enabled (runit)"
