#!/usr/bin/env bash

# Check if the required commands are available
check() {
  command -v "$1" 1>/dev/null
}

# Send notification or print if notify-send is unavailable
notify() {
  check notify-send && {
    notify-send -a "UpdateCheck Waybar" "$@"
    return
  }
  echo "$@"
}

# Format string length with truncation or padding
stringToLen() {
  STRING="$1"
  LEN="$2"
  if [ ${#STRING} -gt "$LEN" ]; then
    echo "${STRING:0:$((LEN - 2))}.."
  else
    printf "%-${LEN}s" "$STRING"
  fi
}

# Ensure necessary utilities are installed
check checkupdates || {
  notify "Ensure pacman-contrib is installed"
  cat <<EOF
  {"text":"ERR","tooltip":"pacman-contrib is not installed"}
EOF
  exit 1
}

check aur || {
  notify "Ensure aurutils is installed"
  cat <<EOF
  {"text":"ERR","tooltip":"aurutils is not installed"}
EOF
  exit 1
}

# Kill any existing checkupdates process
killall -q checkupdates

# Fetch updates from Arch and AUR
cup() {
  checkupdates --nocolor
  pacman -Qm | aur vercmp
}

# Get updates
mapfile -t updates < <(cup)

# Prepare text and tooltip for output
text=${#updates[@]}
tooltip="<b>$text  updates (arch+aur) </b>\n"
tooltip+="<b>$(stringToLen "PkgName" 20) $(stringToLen "PrevVersion" 20) $(stringToLen "NextVersion" 20)</b>\n"

# If no updates, update text to empty, else show update icon
if [ "$text" -eq 0 ]; then
  text=""
else
  text="󰦘"
fi

# Format updates for tooltip
for i in "${updates[@]}"; do
  update="$(stringToLen $(echo "$i" | awk '{print $1}') 20)"
  prev="$(stringToLen $(echo "$i" | awk '{print $2}') 20)"
  next="$(stringToLen $(echo "$i" | awk '{print $4}') 20)"
  tooltip+="<b> $update </b>$prev $next\n"
done

tooltip=${tooltip::-2}  # Remove trailing newline

# Output the JSON formatted text and tooltip
cat <<EOF
{ "text":"$text", "tooltip":"$tooltip"}
EOF
