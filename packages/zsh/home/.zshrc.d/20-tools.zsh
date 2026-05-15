_setup_ssh_agent() {
  eval "$(ssh-agent -s)" >/dev/null 2>&1
  local key=~/.ssh/id_github
  [[ -f "$key" ]] || return
  if [[ "$_DISTRO" == "macos" ]]; then
    ssh-add --apple-use-keychain "$key" 2>/dev/null
  else
    ssh-add "$key" 2>/dev/null
  fi
}

[[ -z "$SSH_AUTH_SOCK" ]] && _setup_ssh_agent

eval "$(fnm env --use-on-cd --shell zsh)"
fnm use default 2>/dev/null || true
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

_atuin_preexec_orig=${_atuin_preexec_orig:-}
_atuin_preexec() {
  [[ -n "${ATUIN_SKIP:-}" ]] && return
  if type _atuin_preexec_orig &>/dev/null; then
    _atuin_preexec_orig "$@"
  fi
}
