# GRUB Setup

## Themes

Two themes are managed by the asset manager:

```
dot assets sync arch-linux-grub   # Arch Linux theme from AdisonCavani/distro-grub-themes
dot assets sync grub-theme        # Custom personal theme (cloned from git)
```

Both install to `/boot/grub/themes/` and require sudo.

## Configuration

Edit `/etc/default/grub`:

```ini
GRUB_THEME="/boot/grub/themes/shad/theme.txt"
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_TIMEOUT=15
GRUB_GFXMODE=1920x1080x32,auto
GRUB_PRELOAD_MODULES="part_gpt part_msdos efi_gop all_video"
```

Regenerate GRUB config after changes:

```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Intel GPU + Wayland

Add to `GRUB_CMDLINE_LINUX_DEFAULT` if using Intel GPU:

```
i915.enable_psr=0 i915.enable_fbc=0
```

## NVIDIA

See `dot docs nvidia` for NVIDIA-specific kernel parameters.
