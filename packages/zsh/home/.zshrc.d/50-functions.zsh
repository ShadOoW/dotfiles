function y() {
  local tmp
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

cf() {
  if [ -z "$1" ]; then
    echo "Usage: cf <filename>"
    return 1
  fi
  echo -n "$1" | wl-copy
  echo "Copied '$1' to clipboard."
}

copyimg() {
  emulate -L zsh

  local file="$1"
  local tmp
  tmp=$(mktemp /tmp/clip-XXXXXX.png) || return 1

  trap 'rm -f "$tmp"' EXIT INT TERM

  if [[ -n "$file" ]]; then
    [[ ! -f "$file" ]] && {
      echo "❌ File not found: $file"
      return 1
    }

    if ! file --mime-type -b "$file" | grep -q '^image/'; then
      echo "❌ Not an image: $file"
      return 1
    fi

    wl-copy <"$file" || {
      echo "❌ Failed to copy to clipboard"
      return 1
    }
  fi

  if ! wl-paste --type image/png >"$tmp" 2>/dev/null; then
    echo "❌ Clipboard does not contain an image"
    return 1
  fi

  ${IMG_VIEWER:-feh} "$tmp"
}

zdrag() {
  ripdrag "$(fzf)"
}

copycommitmsg() {
  local ref="${1:-HEAD}"
  local msg

  msg="$(git log -1 --format=%B "$ref")" || {
    echo "❌ Failed to get commit message for '$ref'"
    return 1
  }

  local copy_cmd
  if [[ "$OSTYPE" == darwin* ]]; then
    copy_cmd="pbcopy"
  elif command -v wl-copy &>/dev/null; then
    copy_cmd="wl-copy"
  elif command -v xclip &>/dev/null; then
    copy_cmd="xclip -selection clipboard"
  elif command -v xsel &>/dev/null; then
    copy_cmd="xsel --clipboard --input"
  else
    echo "❌ No clipboard tool found (tried: wl-copy, xclip, xsel)"
    return 1
  fi

  echo -n "$msg" | $copy_cmd
  echo "✓ Copied commit message for '$ref' to clipboard"
}
