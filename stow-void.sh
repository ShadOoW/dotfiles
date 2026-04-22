#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$SCRIPT_DIR/packages"
BACKUP_DIR="$SCRIPT_DIR/backup"

declare -A TARGET_DIRS=(
  ["ly"]="/etc/ly"
  ["sway"]="$HOME/.config/sway"
  ["rofi"]="$HOME/.config/rofi"
  ["waybar"]="$HOME/.config/waybar"
  ["kitty"]="$HOME/.config/kitty"
  ["mako"]="$HOME/.config/mako"
  ["swayidle"]="$HOME/.config/swayidle"
  ["zsh"]="$HOME"
)

declare -a SETUP_SCRIPTS=()
USERNAME=""

usage() {
  echo "Usage: $0 --username USERNAME"
  echo ""
  echo "Options:"
  echo "  --username USERNAME  Username to replace 'shad' with in all files"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --username)
      USERNAME="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$USERNAME" ]]; then
  usage
fi

mkdir -p "$BACKUP_DIR"

backup_item() {
  local source_path="$1"
  local target_path="$2"
  local relative_path="${target_path#$HOME/}"
  local backup_path="$BACKUP_DIR/$relative_path"
  local use_sudo="$3"

  if [[ ! -e "$source_path" ]] || [[ -L "$source_path" ]]; then
    return
  fi

  mkdir -p "$(dirname "$backup_path")"
  if [[ "$use_sudo" == "true" ]]; then
    sudo cp -r "$source_path" "$backup_path"
    sudo rm -rf "$source_path"
  else
    cp -r "$source_path" "$backup_path"
    rm -rf "$source_path"
  fi
}

process_package() {
  local package="$1"
  local package_dir="$STOW_DIR/$package"

  if [[ ! -d "$package_dir" ]]; then
    echo "[SKIP] $package (no directory)"
    return
  fi

  echo "[INFO] Processing: $package"

  local setup_script="$package_dir/setup.sh"
  if [[ -f "$setup_script" && -x "$setup_script" ]]; then
    SETUP_SCRIPTS+=("$setup_script")
  fi

  local target_dir="${TARGET_DIRS[$package]:-}"
  if [[ -z "$target_dir" ]]; then
    echo "[SKIP] $package (no target mapping)"
    return
  fi

  target_dir="${target_dir/#\$HOME/$HOME}"

  local use_sudo="false"
  if [[ "$target_dir" == "/etc"* ]]; then
    use_sudo="true"
  fi

  mkdir -p "$target_dir"

  while IFS= read -r -d '' file; do
    if [[ "$(basename "$file")" == "setup.sh" ]]; then
      continue
    fi

    local rel_path="${file#$package_dir/}"
    local target_file="$target_dir/$rel_path"
    local target_file_dir="$(dirname "$target_file")"

    mkdir -p "$target_file_dir"

    if [[ -e "$target_file" && ! -L "$target_file" ]]; then
      backup_item "$target_file" "$target_file" "$use_sudo"
    elif [[ -L "$target_file" ]]; then
      rm -f "$target_file"
    fi

    if [[ "$use_sudo" == "true" ]]; then
      sudo ln -sf "$file" "$target_file"
    else
      ln -sf "$file" "$target_file"
    fi
    echo "  -> $target_file"
  done < <(find "$package_dir" -type f -print0)
}

replace_username() {
  local new_username="$1"
  local old_username="shad"

  if [[ "$new_username" == "$old_username" ]]; then
    return
  fi

  while IFS= read -r -d '' file; do
    if [[ "$(basename "$file")" == "setup.sh" ]]; then
      continue
    fi
    if [[ -n "$(file --mime "$file" 2>/dev/null | grep -E 'text|empty')" ]]; then
      sed -i "s|$old_username|$new_username|g" "$file"
    fi
  done < <(find "$STOW_DIR" -type f -print0)
}

run_setup_scripts() {
  for script in "${SETUP_SCRIPTS[@]}"; do
    echo "[INFO] Running: $script"
    "$script"
  done
}

main() {
  echo "[INFO] Stowing packages for Void Linux: ly, sway, kitty"

  replace_username "$USERNAME"

  for pkg in ly sway kitty zsh; do
    process_package "$pkg"
  done

  run_setup_scripts

  echo "[OK] Done"
}

main
