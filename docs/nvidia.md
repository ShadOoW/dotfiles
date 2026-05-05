# NVIDIA Setup

## Packages

Install the NVIDIA driver and related packages:

```
nvidia-dkms
nvidia-settings
nvidia-utils
libva
libva-nvidia-driver
```

For each installed kernel, also install its headers:

```
# find kernels with: ls /usr/lib/modules/
xbps-install linux6.x-headers   # adjust to your kernel version
```

## Kernel Parameters

Add to GRUB (`/etc/default/grub`, `GRUB_CMDLINE_LINUX_DEFAULT`):

```
nvidia-drm.modeset=1 nvidia_drm.fbdev=1
```

Then regenerate GRUB config:

```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## mkinitcpio

Add to `MODULES=()` in `/etc/mkinitcpio.conf`:

```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Rebuild initramfs:

```
sudo mkinitcpio -P
```

## modprobe

Create `/etc/modprobe.d/nvidia.conf`:

```
options nvidia_drm modeset=1 fbdev=1
```

## Intel GPU (if hybrid)

For Intel integrated GPU on Wayland, add to kernel parameters:

```
i915.enable_psr=0 i915.enable_fbc=0
```
