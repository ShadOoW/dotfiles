# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.config/oh-my-zsh"

ZSH_THEME="zhann"

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
    copybuffer
    copyfile
    extract
    nvm
)

source $ZSH/oh-my-zsh.sh

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
# fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat="bat --theme=gruvbox-dark"

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

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
bindkey "^[[5~" cd_up      # Page Up
bindkey "^[[6~" cd_back    # Page Down
bindkey -r '^[[H'
bindkey "^[OH" go_home_dir # Home key
bindkey -r '^[[F'
bindkey "^[OF" run_ls      # End key
