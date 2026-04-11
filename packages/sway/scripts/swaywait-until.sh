#!/bin/sh
# Waits for a window with the given app_id/class to appear, prints its con_id and exits

if [ $# -ne 1 ]; then
  echo "Usage: swaywait-until [app_id/class]"
  exit 1
fi

TARGET=$1
TIMEOUT=10

# Use timeout to prevent hanging on subscribe
timeout $TIMEOUT swaymsg -t subscribe -m '["window"]' | while read line; do
  CON=$(echo "$line" | jq -r 'select(.change=="new").container' 2>/dev/null)
  APPID=$(echo "$CON" | jq -r '.app_id' 2>/dev/null)
  CLASS=$(echo "$CON" | jq -r '.window_properties.class' 2>/dev/null)
  CONID=$(echo "$CON" | jq -r '.id' 2>/dev/null)

  if [ "$APPID" = "$TARGET" ] || [ "$CLASS" = "$TARGET" ]; then
    echo "$CONID"
    exit 0
  fi
done
