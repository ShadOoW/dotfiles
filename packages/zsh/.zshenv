# Wayland environment variables - set for all zsh instances
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Ensure proper XDG directories
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"
