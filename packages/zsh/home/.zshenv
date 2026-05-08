# ZINIT package manager home
export ZINIT_HOME="${ZINIT_HOME:-$HOME/.local/share/zinit/zinit.git}"

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

# XDG directories — only set Linux-specific paths on Linux
if [[ "$(uname)" == "Linux" ]]; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
  export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"
else
  # Unset Linux-only XDG vars that may have been exported by parent shell or dotfiles
  unset XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP 2>/dev/null
fi

typeset -U path PATH

# cpr: copy command output to clipboard
cpr() {
  local cmd="$*"
  if [[ "$(uname)" == "Darwin" ]]; then
    { echo "$ $cmd"; eval "$cmd"; } | pbcopy
  else
    { echo "$ $cmd"; eval "$cmd"; } | wl-copy
  fi
}
