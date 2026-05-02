# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/shad/.zsh/completions:"* ]]; then export FPATH="/home/shad/.zsh/completions:$FPATH"; fi
# Enable Completion
autoload -Uz compinit
compinit

# SSH agent - start if not running, add key if it exists
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null
  [ -f ~/.ssh/id_github ] && ssh-add ~/.ssh/id_github 2>/dev/null
fi

# zinit annexes for binary management
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Load plugins with turbo mode (wait for prompt, then load in background)
# Order matters: compinit first, then fzf-tab, then history-substring-search, then others
zinit ice wait lucid blockf
zinit light Aloxaf/fzf-tab

zinit ice wait lucid blockf
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit snippet OMZP::extract

# Binary releases from GitHub - using official zinit recipes
# fnm - Fast Node Manager
zinit for \
  as'completion' \
  atclone"./fnm completions --shell zsh > _fnm.zsh" \
  atload'eval $(fnm env --shell zsh)' \
  atpull'%atclone' \
  blockf \
  from'gh-r' \
  nocompile \
  sbin'fnm' \
  @Schniz/fnm

# atuin
zinit for \
  from'gh-r' \
  bpick'atuin-x86_64-unknown-linux-gnu.tar.gz' \
  sbin'**/atuin' \
  @atuinsh/atuin

# zoxide - correct repo is ajeetdsouza/zoxide
zinit for \
  from'gh-r' \
  sbin'**/zoxide' \
  @ajeetdsouza/zoxide

# fzf - with shell integration
zinit for \
  from'gh-r' \
  sbin'fzf' \
  atclone'fzf --zsh > fzf.zsh' \
  atpull'%atclone' \
  src'fzf.zsh' \
  @junegunn/fzf

# broot
zinit for \
  from'gh-r' \
  sbin'**/broot' \
  @Canop/broot

# lsd
zinit for \
  from'gh-r' \
  sbin'**/lsd' \
  @lsd-rs/lsd

# bat
zinit for \
  from'gh-r' \
  sbin'**/bat' \
  @sharkdp/bat

# Set-up icons for files/directories in terminal using lsd
# Configure LS_COLORS for better readability (especially for mounted directories)
export LS_COLORS="di=01;94:ln=01;36:so=01;35:pi=40;33:ex=01;32:bd=40;33;01:cd=40;33;01:su=37;41:sg=30;43:tw=30;42:ow=01;94:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:st=37;44:ex=01;32"

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat="bat --theme=gruvbox-dark"
alias drag="ripdrag"
alias n="nvim"

# Yazi: change shell CWD on exit
function y() {
  local tmp
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Function to copy file content to clipboard
cf() {
  if [ -z "$1" ]; then
    echo "Usage: cf <filename>"
    return 1
  fi
  echo -n "$1" | wl-copy
  echo "Copied '$1' to clipboard."
}

copyimg() {
  emulate -L zsh

  local file="$1"
  local tmp
  tmp=$(mktemp /tmp/clip-XXXXXX.png) || return 1

  # Always cleanup
  trap 'rm -f "$tmp"' EXIT INT TERM

  # If file provided → copy it
  if [[ -n "$file" ]]; then
    [[ ! -f "$file" ]] && {
      echo "❌ File not found: $file"
      return 1
    }

    # Validate it's an image
    if ! file --mime-type -b "$file" | grep -q '^image/'; then
      echo "❌ Not an image: $file"
      return 1
    fi

    wl-copy <"$file" || {
      echo "❌ Failed to copy to clipboard"
      return 1
    }
  fi

  # Ensure clipboard actually contains an image
  if ! wl-paste --type image/png >"$tmp" 2>/dev/null; then
    echo "❌ Clipboard does not contain an image"
    return 1
  fi

  # Preview (allow override via $IMG_VIEWER)
  ${IMG_VIEWER:-feh} "$tmp"
}

# Function to use fzf with ripdrag
zdrag() {
  ripdrag "$(fzf)"
}

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt extended_history  # Store timestamps for Atuin import compatibility
setopt histignorealldups # Don't save duplicate entries in history
setopt sharehistory      # Share history between all sessions
setopt incappendhistory  # Immediately append to history file

eval "$(zoxide init zsh)"

# Define widgets
function cd_up() {
  BUFFER="cd .."
  zle accept-line
}
function cd_back() {
  BUFFER="cd -"
  zle accept-line
}
function go_home_dir() {
  BUFFER="cd ~"
  zle accept-line
}
function run_ls() {
  BUFFER="ls"
  zle accept-line
}

# Create zle widgets
zle -N cd_up
zle -N cd_back
zle -N go_home_dir
zle -N run_ls

# Bind Page Up and Page Down
bindkey "^[[5~" cd_up   # Page Up
bindkey "^[[6~" cd_back # Page Down
bindkey -r '^[[H'
bindkey "^[OH" go_home_dir # Home key
bindkey -r '^[[F'
bindkey "^[OF" run_ls # End key

# Configure history substring search
bindkey '^[[A' history-substring-search-up   # Up arrow
bindkey '^[[B' history-substring-search-down # Down arrow
bindkey '^[OA' history-substring-search-up   # Up arrow (alternate)
bindkey '^[OB' history-substring-search-down # Down arrow (alternate)

# Word navigation with Ctrl+Left and Ctrl+Right
bindkey "^[[1;5D" backward-word # Ctrl+Left
bindkey "^[[1;5C" forward-word  # Ctrl+Right
# Alternative key codes for some terminals
bindkey "^[Od" backward-word # Ctrl+Left (alternate)
bindkey "^[Oc" forward-word  # Ctrl+Right (alternate)

# Improved prompt
autoload -Uz vcs_info
precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt prompt_subst
PROMPT='%B%F{blue}%c%B%F{magenta} %{$reset_color%}% %F{red}❯%F{yellow}❯%F{green}❯%f '
RPROMPT='%B%F{green}${vcs_info_msg_0_}%f'

# Atuin: Alt+Down = global search, Alt+Up = directory-scoped search
eval "$(atuin init zsh)"
bindkey '^[[1;3B' atuin-search    # Alt+Down for global search
bindkey '^[[1;3A' atuin-up-search # Alt+Up for directory mode

# Skip Atuin recording when ATUIN_SKIP is set (Cursor/VSCode user settings)
functions[_atuin_preexec_orig]=${functions[_atuin_preexec]}
_atuin_preexec() {
  [[ -n "${ATUIN_SKIP:-}" ]] && return
  _atuin_preexec_orig "$@"
}
. "/home/shad/.deno/env"

# bun completions
[ -s "/home/shad/.bun/_bun" ] && source "/home/shad/.bun/_bun"
