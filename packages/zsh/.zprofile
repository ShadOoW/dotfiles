if [ -z "$SSH_AUTH_SOCK" ]; then
  # If ssh-agent is not running, start it
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

# Add GitHub SSH key if not already added
if ! ssh-add -l | grep -q id_github; then
  ssh-add ~/.ssh/id_github 2>/dev/null
fi
