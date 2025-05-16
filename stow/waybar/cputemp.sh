#!/usr/bin/env bash

# Check if required commands are available
check() {
  command -v "$1" >/dev/null 2>&1
}

check sensors || {
  echo '{"text":"N/A","tooltip":"lm-sensors not found","class":"disconnected"}'
  exit 1
}

# Detect available coretemp sensor name
sensor_name=$(sensors | grep -m1 -oE '^[^:]+coretemp[^:]*')
[ -z "$sensor_name" ] && {
  echo '{"text":"N/A","tooltip":"No coretemp sensor found","class":"disconnected"}'
  exit 1
}

# Get sensor output and extract relevant values
sensor_output=$(sensors "$sensor_name")
package_temp=$(echo "$sensor_output" | awk -F'[:+]' '/Package id 0/ {gsub("°C",""); print $3}')
core_temps=$(echo "$sensor_output" | awk -F'[:+]' '/Core [0-9]+/ {gsub("°C",""); print $3}')

# Sanity check
[ -z "$package_temp" ] && {
  echo '{"text":"N/A","tooltip":"Temperature data unavailable","class":"disconnected"}'
  exit 1
}

# Convert to integer for threshold comparisons
temp_int=${package_temp%.*}
temp_text="<b>${temp_int}󰔄</b>"

# Default icon and class
icon=""
class="cool"

# Set class and icon based on temperature thresholds
if (( temp_int > 95 )); then
  icon=""
  class="critical"
elif (( temp_int > 85 )); then
  icon=""
  class="warn"
elif (( temp_int > 70 )); then
  icon=""
  class="warm"
elif (( temp_int > 50 )); then
  icon=""
  class="normal"
fi

# Build tooltip with all core temps
tooltip="<b>Package Temp: ${package_temp}°C</b>\n"
i=0
while read -r core; do
  tooltip+="Core $i: ${core}°C\n"
  ((i++))
done <<< "$core_temps"

# Remove last newline and escape tooltip
tooltip="${tooltip::-1}"
tooltip_escaped=$(echo -e "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

# Output JSON
cat <<EOF
{"text":"$temp_text","tooltip":"$tooltip_escaped", "class": "$class"}
EOF
