# Enable Completion
autoload -Uz compinit
compinit

# Source plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# FZF plugins
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh
source /usr/share/zsh/plugins/zsh-fzf-plugin/fzf.plugin.zsh 

# Fast Node Manager (FNM)
eval "$(fnm env --use-on-cd --shell zsh)"

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

# Function to copy file content to clipboard
cf() {
  if [ -z "$1" ]; then
    echo "Usage: cf <filename>"
    return 1
  fi
  echo -n "$1" | wl-copy
  echo "Copied '$1' to clipboard."
}

# Function to use fzf with ripdrag
zdrag() {
  ripdrag "$(fzf)"
}

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt histignorealldups  # Don't save duplicate entries in history
setopt sharehistory       # Share history between all sessions
setopt incappendhistory   # Immediately append to history file

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

cpr() {
  local cmd="$*"
  {
    echo "$ $cmd"
    eval "$cmd"
  } | wl-copy
}

# Create zle widgets
zle -N cd_up
zle -N cd_back
zle -N go_home_dir
zle -N run_ls

# Bind Page Up and Page Down
bindkey "^[[5~" cd_up      # Page Up
bindkey "^[[6~" cd_back    # Page Down
bindkey -r '^[[H'
bindkey "^[OH" go_home_dir # Home key
bindkey -r '^[[F'
bindkey "^[OF" run_ls      # End key

# Configure history substring search
bindkey '^[[A' history-substring-search-up      # Up arrow
bindkey '^[[B' history-substring-search-down    # Down arrow
bindkey '^[OA' history-substring-search-up      # Up arrow (alternate)
bindkey '^[OB' history-substring-search-down    # Down arrow (alternate)

# Word navigation with Ctrl+Left and Ctrl+Right
bindkey "^[[1;5D" backward-word                 # Ctrl+Left
bindkey "^[[1;5C" forward-word                  # Ctrl+Right
# Alternative key codes for some terminals
bindkey "^[Od" backward-word                    # Ctrl+Left (alternate)
bindkey "^[Oc" forward-word                     # Ctrl+Right (alternate)

# Improved prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt prompt_subst
PROMPT='%B%F{blue}%c%B%F{magenta} %{$reset_color%}% %F{red}❯%F{yellow}❯%F{green}❯%f '
RPROMPT='%B%F{green}${vcs_info_msg_0_}%f'

# Function to watch directory as a tree
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PRETTIERD_DEFAULT_CONFIG="$HOME/.config/prettierd/.prettierrc"

source /home/shad/.config/broot/launcher/bash/br
export JAVA_HOME=/usr/lib/jvm/java-24-openjdk
