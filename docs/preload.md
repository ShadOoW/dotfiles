# Preload

Preload adaptively preloads frequently-used applications into memory, reducing launch times.

## Install

Available via AUR on Arch or from source on other distros:

```
# Arch (AUR)
yay -S preload

# Void Linux: not in official repos, build from source or skip
```

## Enable

```
sudo systemctl enable --now preload.service
```

## Configuration

The config file is at `/etc/preload.conf`. Default settings are suitable for most users.

Preload runs silently in the background and learns your usage patterns over time.
