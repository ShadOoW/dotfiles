# zram - ZRAM swap configuration

## System Packages (Void Linux)

```
xbps-install zramen zram-service
```

## Setup

1. **Link system files**: `sudo dot link-system zram --init runit` or `--init systemd`
   - `system/base/` - generic configs (always linked)
   - `system/systemd/` - systemd-specific configs (only if `--init systemd`)

   Files linked:
   - `system/base/etc/modules-load.d/zram.conf` → `/etc/modules-load.d/zram.conf`
   - `system/systemd/etc/systemd/zram-generator.conf` → `/etc/systemd/zram-generator.conf` (systemd only)

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
