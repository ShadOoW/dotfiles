#!/bin/bash
set -e

aur_pkg=(
  neovim
  nvim-lazy
  luarocks
  markdownlint-cli2
  vscode-langservers-extracted
  superhtml-bin
  ctags
  pandoc-cli
  glow

  # Formatters
  stylua
  shfmt
  shellcheck
  eslint_d
  prettierd
  prettier  # standalone — used by `just format` for JSON/MD/CSS
  ruff      # Python formatter (replaces black/isort)
  taplo-cli # TOML formatter
  kdlfmt    # KDL formatter (zellij config)

  # Dotfiles tooling
  just              # task runner (`just format` / `just check`)
  python-pre-commit # git hooks — auto-formats staged files on commit

  # Git multi-repo tools
  multi-git-status
)

# Source global functions
GLOBAL_SH="$(dirname "$(readlink -f "$0")")/../../utils/global.sh"
if ! source "$GLOBAL_SH"; then
  log "error" "Failed to source global.sh"
  exit 1
fi

# Install base packages
log "info" "Installing base packages"
install_packages_aur "${aur_pkg[@]}" || exit 1

# Create Neovim temporary directories
NVIM_DIRS=(
  "/tmp/nvim/swap/"
  "/tmp/nvim/backup/"
  "/tmp/nvim/undo/"
)

log "info" "Creating Neovim temporary directories"
for dir in "${NVIM_DIRS[@]}"; do
  if ! mkdir -p "$dir"; then
    log "error" "Failed to create directory: $dir"
    exit 1
  fi

  # Set permissions to 700 (rwx------)
  if ! chmod 700 "$dir"; then
    log "error" "Failed to set permissions for: $dir"
    exit 1
  fi

  # Verify write permissions
  if ! touch "$dir/test_write" 2>/dev/null; then
    log "error" "Directory not writable: $dir"
    exit 1
  fi
  rm -f "$dir/test_write"

  log "success" "Directory created and writable: $dir"
done

# Install bluetooth packages
log "info" "Installing bluetooth packages"
install_packages_pacman "${blue_pkg[@]}" || exit 1

log "success" "Neovim installation completed successfully"

# Install pre-commit hook into the dotfiles repo
DOTFILES_ROOT="$(dirname "$(readlink -f "$0")")/../.."
log "info" "Installing pre-commit hook"
if (cd "$DOTFILES_ROOT" && pre-commit install); then
  log "success" "pre-commit hook installed"
else
  log "warning" "pre-commit install failed — run 'just setup' manually from the dotfiles root"
fi
