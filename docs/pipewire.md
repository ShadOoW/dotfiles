# PipeWire Setup

PipeWire replaces PulseAudio and JACK for modern Wayland desktops.

## Packages

```
pipewire
wireplumber
pipewire-audio
pipewire-alsa
pipewire-pulse
sof-firmware      # firmware for Intel HDA / SOF audio
pavucontrol       # GUI volume control
```

## Disable PulseAudio (if installed)

```
systemctl --user disable --now pulseaudio.socket pulseaudio.service
```

## Enable PipeWire

```
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
systemctl --user enable --now pipewire.service
```

## Verify

```
pactl info | grep "Server Name"
# Should show: PulseAudio (on PipeWire ...)
```
