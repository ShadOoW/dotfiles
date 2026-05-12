# zsh - Zsh configuration with Zinit plugin manager

## Required packages

### Arch Linux (pacman)

```
pacman -S zsh fzf zoxide atuin
cargo install fnm
```

### Void Linux (xbps)

```
xbps-install zsh fzf zoxide atuin
cargo install fnm
```

### macOS (brew)

```
brew install zsh fzf zoxide atuin fnm
```

## Post-install

- zinit auto-installs itself on first shell launch
- Restart shell after linking to initialize zinit
