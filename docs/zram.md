# zram Setup

zram creates a compressed RAM-backed swap device, reducing disk I/O and improving responsiveness on systems with limited memory.

## Package

```
xbps-install zram-generator   # Void Linux
pacman -S zram-generator       # Arch Linux
```

## Configuration

The config file is already managed by the `zram` package in this dotfiles repo:

```
dot link zram
```

This links `/etc/systemd/zram-generator.conf` with settings for a 4GB zram swap device using zstd compression.

## Enable

```
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0
```

It starts automatically on boot via systemd once the config is in place.
