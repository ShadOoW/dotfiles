#!/bin/bash
# Claude Code weekly quota waybar module - shows % of weekly quota remaining

CACHE="/tmp/waybar-claude-weekly-cache.json"
CACHE_TTL=300
WEEKLY_LIMIT=50 # $50/week default

NOW=$(date +%s)
CACHE_MTIME=0
[ -f "$CACHE" ] && CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || echo 0)

if [ $((NOW - CACHE_MTIME)) -ge $CACHE_TTL ]; then
  RAW=$(npx ccusage@latest weekly --json --offline 2>/dev/null)
  printf '%s' "$RAW" >"$CACHE"
else
  RAW=$(cat "$CACHE")
fi

if [ -z "$RAW" ] || [ "$RAW" = "null" ]; then
  jq -cn '{"text": "Ø", "tooltip": "Error: ccusage failed\nCheck npm installation", "class": "claude-inactive"}'
  exit 0
fi

# Parse weekly usage - get current week's total cost
COST=$(echo "$RAW" | jq -r '.weekly[0].totalCost // 0')

if [ "$COST" = "null" ] || [ -z "$COST" ]; then
  jq -cn '{"text": "Ø", "tooltip": "No usage this week\nLimit: $50/week", "class": "claude-inactive"}'
  exit 0
fi

# Calculate percentage used
USED_PCT=$(echo "scale=0; $COST * 100 / $WEEKLY_LIMIT" | bc)
[ "$USED_PCT" -gt 100 ] 2>/dev/null && USED_PCT=100
[ "$USED_PCT" -lt 0 ] 2>/dev/null && USED_PCT=0
[ -z "$USED_PCT" ] && USED_PCT=0

if [ "$USED_PCT" -ge 80 ]; then
  CLASS="claude-high"
elif [ "$USED_PCT" -ge 50 ]; then
  CLASS="claude-mid"
else
  CLASS="claude-low"
fi

COST_FMT=$(printf '$%.2f' "$COST")
LIMIT_FMT=$(printf '$%d' "$WEEKLY_LIMIT")
REMAIN_VAL=$(echo "scale=2; $WEEKLY_LIMIT - $COST" | bc)
REMAIN_FMT=$(printf '$%.2f' "$REMAIN_VAL")

TOOLTIP_STR="Weekly Quota
Used: ${COST_FMT} / ${LIMIT_FMT}
Remaining: ${REMAIN_FMT} (${USED_PCT}% used)"

# Use printf to preserve newlines
NL=$'\n'
TEXT="<span color=\"#7dcfff\">W</span>${NL}${USED_PCT}"

jq -cn \
  --arg text "$TEXT" \
  --arg tooltip "$TOOLTIP_STR" \
  --arg cls "$CLASS" \
  --argjson pct "$USED_PCT" \
  '{"text": $text, "tooltip": $tooltip, "class": $cls, "percentage": $pct}'
