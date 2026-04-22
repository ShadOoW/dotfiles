# rofi - Application launcher and window switcher

## System Packages (Void Linux)

```
xbps-install rofi
```

## Setup

```bash
dot link-home rofi
```

## Keybindings (Sway)

- `mod+d` - Application launcher (run)
- `mod+x` - Window switcher (sway-windows)
- `mod+c` - Clipboard history
- `mod+shift+d` - Custom commands (vivaldi PWAs + system commands)

## Scripts

- `open-close.sh` - Toggle rofi menus, handles multiple instances
- `sway-windows.sh` - Window switcher with PWA icons for Vivaldi
- `custom-commands.sh` - Custom command launcher with Vivaldi PWA entries
