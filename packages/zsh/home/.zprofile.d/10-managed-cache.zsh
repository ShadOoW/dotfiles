if [ -f "$HOME/.cache/.managed" ]; then
  mkdir -p "$HOME/.cache/managed-zinit/polaris"
  export ZINIT_HOME="$HOME/.cache/managed-zinit/polaris/bin/zinit.git"
else
  export ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
fi

if [ -f "$HOME/.cache/.managed" ]; then
  export npm_config_cache="$HOME/.cache/managed-npm"
  mkdir -p "$npm_config_cache"
fi

if [ -f "$HOME/.cache/.managed" ]; then
  export FNM_DIR="$HOME/.cache/managed-fnm"
  mkdir -p "$FNM_DIR"
fi

if [ -f "$HOME/.cache/.managed" ]; then
  export RUSTUP_HOME="$HOME/.cache/managed-rustup"
  mkdir -p "$RUSTUP_HOME"
fi
