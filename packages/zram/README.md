# zram - ZRAM swap configuration

## System Packages (Void Linux)

```
xbps-install zramen zram-service
```

## Setup

1. **Link system files**: `sudo dot link-system zram --init runit`
   - Links `/etc/modules-load.d/zram.conf` (generic, works for both)
   - For systemd: also links `/etc/systemd/zram-generator.conf`

2. **Enable service**:
   - Runit: `sudo dot enable zram --init runit`
   - Systemd: `sudo dot enable zram --init systemd`

## Runit (zramen)

zramen reads config from `/etc/sv/zramen/conf` (environment variables).
Default: 25% RAM, lz4, priority 32767.

## Systemd (zram-generator)

Config: 75% RAM, zstd, priority 100.

## Clean

```bash
sudo dot unlink-system zram
```
