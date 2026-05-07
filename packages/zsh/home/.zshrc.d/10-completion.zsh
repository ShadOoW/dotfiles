[[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" $fpath)
[[ -d "$HOME/.bun" ]] && fpath=("$HOME/.bun" $fpath)

autoload -Uz compinit
# Only do a full security scan if the dump is older than 24h; otherwise use cache
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zinit cdreplay -q
