if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null
  [ -f ~/.ssh/id_github ] && ssh-add ~/.ssh/id_github 2>/dev/null
fi

# FNM_DIR set in .zprofile.d/10-managed-cache.zsh — must be before this eval
eval "$(fnm env --use-on-cd --shell zsh)"

eval "$(zoxide init zsh)"

eval "$(atuin init zsh)"

# Skip Atuin recording when ATUIN_SKIP is set (Cursor/VSCode)
functions[_atuin_preexec_orig]=${functions[_atuin_preexec]}
_atuin_preexec() {
  [[ -n "${ATUIN_SKIP:-}" ]] && return
  _atuin_preexec_orig "$@"
}
