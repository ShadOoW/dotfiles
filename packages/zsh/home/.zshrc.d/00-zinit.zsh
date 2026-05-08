# ZINIT[] associative array — must be set before sourcing zinit.zsh
typeset -gA ZINIT
if [ -f "$HOME/.cache/.managed" ]; then
  ZINIT[HOME_DIR]="$HOME/.cache/managed-zinit/polaris"
  ZINIT[PLUGINS_DIR]="$HOME/.cache/managed-zinit/polaris/plugins"
  ZINIT[SNIPPETS_DIR]="$HOME/.cache/managed-zinit/polaris/snippets"
  ZINIT[COMPLETIONS_DIR]="$HOME/.cache/managed-zinit/polaris/completions"
fi
ZINIT[COMPINIT_OPTS]="-C"

[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait"0" lucid light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

zinit ice wait"1" lucid blockf
zinit light Aloxaf/fzf-tab

zinit ice wait"1" lucid blockf
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"1" lucid atload'
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
  bindkey "^[OA" history-substring-search-up
  bindkey "^[OB" history-substring-search-down
'
zinit light zsh-users/zsh-history-substring-search

zinit ice wait"1" lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait"1" lucid
zinit snippet OMZP::extract
