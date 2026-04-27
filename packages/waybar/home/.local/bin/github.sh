#!/usr/bin/env bash

# Check if a command exists
check_command() {
  command -v "$1" &>/dev/null
}

# Send a notification using fyi or fallback to echo
notify() {
  if check_command fyi; then
    fyi "$@"
  else
    echo "$@"
  fi
}

# Ensure GitHub token file exists
token_file="$HOME/.ssh/github.token"
if [[ ! -f "$token_file" ]]; then
  notify "Ensure you have placed the token in $token_file"
  cat <<EOF
  {"text":"NaN","tooltip":"Token was not found"}
EOF
  exit 1
fi

# Fetch the token
token=$(<"$token_file")

# Fetch GitHub notifications count using the token
count=$(curl -su ShadOoW:"$token" https://api.github.com/notifications | jq '. | length')

# If the count is empty, set it to 0
count="${count:-0}"

# Output the result in a JSON format
if [[ "$count" -gt 0 ]]; then
  cat <<EOF
  {"text":"\n$count","tooltip":"<b>Github: $count Notifications</b>"}
EOF
else
  cat <<EOF
  {"text":"","tooltip":"<b>Github: $count Notifications</b>"}
EOF
fi
