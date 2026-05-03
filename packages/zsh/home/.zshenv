# PATH needed by scripts and non-interactive shells
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.config/signal-sync:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export EDITOR=nvim
export PASSWORD_STORE_DIR=/data/stash/pass
export PRETTIERD_DEFAULT_CONFIG="$HOME/.config/prettierd/.prettierrc"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"

typeset -U path PATH

# cpr: copy command output to clipboard (available in non-interactive shells, e.g. nvim :!)
cpr() {
  local cmd="$*"
  {
    echo "$ $cmd"
    eval "$cmd"
  } | wl-copy
}
