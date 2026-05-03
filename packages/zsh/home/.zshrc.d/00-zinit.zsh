# ZINIT[] associative array is not exported between processes — must be set here
# before sourcing zinit.zsh, otherwise zinit defaults to ~/.local/share/zinit
if [ -f "$HOME/.cache/.managed" ]; then
  typeset -gA ZINIT
  ZINIT[HOME_DIR]="$HOME/.cache/managed-zinit/polaris"
  ZINIT[PLUGINS_DIR]="$HOME/.cache/managed-zinit/polaris/plugins"
  ZINIT[SNIPPETS_DIR]="$HOME/.cache/managed-zinit/polaris/snippets"
  ZINIT[COMPLETIONS_DIR]="$HOME/.cache/managed-zinit/polaris/completions"
fi
# Tell zinit's internal compinit to use the cached dump
ZINIT[COMPINIT_OPTS]="-C"

[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# wait"0": annexes — must be loaded before binary tools use their ices (sbin, from'gh-r')
zinit wait"0" lucid light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# wait"1": binary tools — shims in $ZPFX/bin persist across sessions so tools are
# callable immediately; these declarations verify/update in the background
zinit ice wait"1" lucid as'completion' atclone"./fnm completions --shell zsh > _fnm.zsh" atpull'%atclone' blockf from'gh-r' nocompile sbin'fnm'
zinit light @Schniz/fnm

zinit ice wait"1" lucid from'gh-r' bpick'atuin-x86_64-unknown-linux-gnu.tar.gz' sbin'**/atuin'
zinit light @atuinsh/atuin

zinit ice wait"1" lucid from'gh-r' sbin'**/zoxide'
zinit light @ajeetdsouza/zoxide

zinit ice wait"1" lucid from'gh-r' sbin'fzf' atclone'fzf --zsh > fzf.zsh' atpull'%atclone' src'fzf.zsh'
zinit light @junegunn/fzf

zinit ice wait"1" lucid from'gh-r' sbin'**/broot'
zinit light @Canop/broot

zinit ice wait"1" lucid from'gh-r' sbin'**/lsd'
zinit light @lsd-rs/lsd

zinit ice wait"1" lucid from'gh-r' sbin'**/bat'
zinit light @sharkdp/bat

# wait"2": UI plugins — fzf-tab before autosuggestions/syntax-highlighting
zinit ice wait"2" lucid blockf
zinit light Aloxaf/fzf-tab

zinit ice wait"2" lucid blockf
zinit light zsh-users/zsh-autosuggestions

# Bindings via atload so widgets exist when bindkey runs
zinit ice wait"2" lucid atload'
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
  bindkey "^[OA" history-substring-search-up
  bindkey "^[OB" history-substring-search-down
'
zinit light zsh-users/zsh-history-substring-search

zinit ice wait"2" lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait"2" lucid
zinit snippet OMZP::extract

[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
