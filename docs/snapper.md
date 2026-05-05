# Snapper (BTRFS Snapshots)

Snapper automates BTRFS snapshots for system rollback.

## Package

```
xbps-install snapper   # Void Linux
pacman -S snapper       # Arch Linux
```

## Configuration

Config and hooks are managed by dotfiles packages:

```
dot link snapper-config   # /etc/snapper/configs/root
dot link snapper-hooks    # pacman hooks for auto-snapshots (Arch only)
```

Then run the setup script:

```
sudo packages/snapper-config/setup.sh
```

## Note

Remove Timeshift if installed — it conflicts with snapper's BTRFS subvolume layout:

```
sudo pacman -Rns timeshift
```
