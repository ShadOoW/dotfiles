if [ -f "$HOME/.cache/.managed" ]; then
  mkdir -p "$HOME/.cache/managed-zinit/polaris"
  export ZINIT_HOME="$HOME/.cache/managed-zinit/polaris/bin/zinit.git"
  export npm_config_cache="$HOME/.cache/managed-npm"
  mkdir -p "$npm_config_cache"
  export FNM_DIR="$HOME/.cache/managed-fnm"
  mkdir -p "$FNM_DIR"
  export RUSTUP_HOME="$HOME/.cache/managed-rustup"
  mkdir -p "$RUSTUP_HOME"
else
  export ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
fi
