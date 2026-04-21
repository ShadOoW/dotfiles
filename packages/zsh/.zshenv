# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# cargo
. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/signal-sync:$PATH"
export PATH="$HOME/.go/bin:$PATH"

# Wayland environment variables - set for all zsh instances
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Ensure proper XDG directories
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"

export PRETTIERD_DEFAULT_CONFIG="$HOME/.config/prettierd/.prettierrc"
export PASSWORD_STORE_DIR=/data/stash/pass
export EDITOR=nvim
export JAVA_HOME=/usr/lib/jvm/java-26-openjdk
export ATUIN_NOBIND='true'

# zinit installation
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

# cpr: copy command output to clipboard (available in non-interactive shells, e.g. nvim :!)
cpr() {
  local cmd="$*"
  {
    echo "$ $cmd"
    eval "$cmd"
  } | wl-copy
}
