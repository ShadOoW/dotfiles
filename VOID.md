# Void Linux Setup

Personal reference for Void Linux package installation and configuration.

---

## Display Manager: ly

### Install

```sh
xbps-install ly
```

### Service (runit)

```sh
rm /var/service/agetty-tty2
ln -s /etc/sv/ly /var/service/ly
```

### Configuration

```sh
# Stow the ly config
./stow.sh --username <your-user> ly

# Make login script executable and configure ly
chmod +x /etc/ly/login.sh
sudo sed -i 's|^login_cmd = .*|login_cmd = /etc/ly/login.sh|' /etc/ly/config.ini
sudo mkdir -p /usr/share/xsessions
```

---

## Window Manager: sway

### Install

```sh
xbps-install sway swaybg swayidle swaylock wl-clipboard grim slurp jq brightnessctl
```

### Terminal

```sh
xbps-install kitty
```

### Launcher / Bar

```sh
xbps-install rofi waybar
```

### Audio (for pactl keybindings)

```sh
xbps-install pipewire pipewire-pulse wireplumber
ln -s /etc/sv Pipewire-Pulse /var/service/
ln -s /etc/sv/wireplumber /var/service/
```

### Build from source

**autotiling-rs** (workspace auto-tiling)

```sh
cargo install autotiling
```

**cliphist** (clipboard manager)

```sh
go install github.com/sentriz/cliphist@latest
```

**iwmenu** (wifi menu)

```sh
# Clone and build from source
git clone https://github.com/JoseExposito/iwmenu.git
cd iwmenu && cargo build --release
sudo cp target/release/iwmenu /usr/local/bin/
```

**wluma** (adaptive brightness)

```sh
cargo install wluma
```

### Configuration

```sh
# Stow sway config
./stow.sh --username <your-user> sway

# Stow rofi
./stow.sh --username <your-user> rofi

# Stow waybar
./stow.sh --username <your-user> waybar

# Stow kitty
./stow.sh --username <your-user> kitty
```

---

## kitty

### Install

```sh
xbps-install kitty
```

### Configuration

```sh
./stow.sh --username <your-user> kitty
```

---

## Packages installed so far

| Package        | xbps | Build | Stowed |
| -------------- | ---- | ----- | ------ |
| ly             | [x]  |       | [ ]    |
| sway           | [ ]  |       | [ ]    |
| swaybg         | [ ]  |       | -      |
| swayidle       | [ ]  |       | -      |
| swaylock       | [ ]  |       | -      |
| wl-clipboard   | [ ]  |       | -      |
| grim           | [ ]  |       | -      |
| slurp          | [ ]  |       | -      |
| jq             | [ ]  |       | -      |
| brightnessctl  | [ ]  |       | -      |
| kitty          | [ ]  |       | [ ]    |
| rofi           | [ ]  |       | [ ]    |
| waybar         | [ ]  |       | [ ]    |
| pipewire       | [ ]  |       | -      |
| pipewire-pulse | [ ]  |       | -      |
| wireplumber    | [ ]  |       | -      |
| autotiling-rs  |      | [ ]   | -      |
| cliphist       |      | [ ]   | -      |
| iwmenu         |      | [ ]   | -      |
| wluma          |      | [ ]   | -      |
