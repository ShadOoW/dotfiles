# Void Linux Setup

Personal reference for Void Linux package installation and configuration.

---

## Display Manager: ly

```sh
xbps-install ly
dot link ly --init runit
dot configure ly
dot enable ly --init runit
```

Disable the conflicting getty:

```sh
rm /var/service/agetty-tty2
```

---

## Window Manager: sway

```sh
xbps-install sway swaybg swayidle swaylock wl-clipboard grim slurp jq brightnessctl
dot link sway
dot link waybar
dot link rofi
dot link kitty
```

### Audio

```sh
xbps-install pipewire pipewire-pulse wireplumber
ln -s /etc/sv/pipewire-pulse /var/service/
ln -s /etc/sv/wireplumber /var/service/
```

### Build from source

```sh
cargo install autotiling    # workspace auto-tiling
cargo install wluma         # adaptive brightness
go install github.com/sentriz/cliphist@latest  # clipboard manager
```

**iwmenu** (wifi menu):

```sh
git clone https://github.com/JoseExposito/iwmenu.git
cd iwmenu && cargo build --release
sudo cp target/release/iwmenu /usr/local/bin/
```

---

## Shell (zsh)

```sh
xbps-install zsh fzf zoxide atuin
cargo install fnm           # Node version manager
dot link zsh
```

Note: zinit installs itself on first shell launch.

---

## Editors

```sh
xbps-install neovim python3-neovim tree-sitter ripgrep fd
dot link nvim

xbps-install helix
cargo install helix
dot link helix
```

---

## Terminal multiplexers

```sh
xbps-install tmux
dot link tmux
```

---

## File managers

```sh
cargo install yazi
dot link yazi
```

---

## System

```sh
# Compressed swap
dot link zram --init runit
dot enable zram --init runit

# Keyboard remapping
xbps-install kanata
dot link kanata
```

---

## Installed packages tracker

| Package    | xbps | Cargo/Go | Linked |
| ---------- | ---- | -------- | ------ |
| ly         | ✓    |          |        |
| sway       | ✓    |          |        |
| waybar     | ✓    |          |        |
| kitty      | ✓    |          |        |
| rofi       | ✓    |          |        |
| pipewire   | ✓    |          | -      |
| zsh        | ✓    |          |        |
| fzf        | ✓    |          | -      |
| zoxide     | ✓    |          | -      |
| atuin      | ✓    |          | -      |
| fnm        |      | ✓        | -      |
| neovim     | ✓    |          |        |
| helix      | ✓    |          |        |
| tmux       | ✓    |          |        |
| yazi       | ✓    |          |        |
| autotiling |      | ✓        | -      |
| cliphist   |      | ✓        | -      |
| wluma      |      | ✓        | -      |
| iwmenu     |      | ✓        | -      |
