if [ -z "$SSH_AUTH_SOCK" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [ -f ~/.ssh/id_github ] && ssh-add --apple-use-keychain ~/.ssh/id_github 2>/dev/null
  else
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [ -f ~/.ssh/id_github ] && ssh-add ~/.ssh/id_github 2>/dev/null
  fi
fi

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

_atuin_preexec_orig=${_atuin_preexec_orig:-}
_atuin_preexec() {
  [[ -n "${ATUIN_SKIP:-}" ]] && return
  if type _atuin_preexec_orig &>/dev/null; then
    _atuin_preexec_orig "$@"
  fi
}