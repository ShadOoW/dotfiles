#!/bin/bash
# Claude Code waybar module - shows % of billing block elapsed
# Tooltip has full session details on hover

CACHE="/tmp/waybar-claude-cache.json"
CACHE_TTL=25

NOW=$(date +%s)
CACHE_MTIME=0
[ -f "$CACHE" ] && CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || echo 0)

if [ $((NOW - CACHE_MTIME)) -ge $CACHE_TTL ]; then
  RAW=$(npx ccusage@latest blocks --active --json --offline 2>/dev/null)
  printf '%s' "$RAW" >"$CACHE"
else
  RAW=$(cat "$CACHE")
fi

BLOCK=$(echo "$RAW" | jq '.blocks[0] // empty' 2>/dev/null)

if [ -z "$BLOCK" ]; then
  jq -cn '{"text": "--", "tooltip": "No active session", "class": "claude-inactive"}'
  exit 0
fi

START=$(echo "$BLOCK" | jq -r '.startTime')
END=$(echo "$BLOCK" | jq -r '.endTime')
COST=$(echo "$BLOCK" | jq -r '.costUSD')
COST_HR=$(echo "$BLOCK" | jq -r '.burnRate.costPerHour')
OUTPUT_TOK=$(echo "$BLOCK" | jq -r '.tokenCounts.outputTokens')
PROJ_COST=$(echo "$BLOCK" | jq -r '.projection.totalCost')

START_EPOCH=$(date -d "$START" +%s)
END_EPOCH=$(date -d "$END" +%s)
TOTAL=$((END_EPOCH - START_EPOCH))
ELAPSED=$((NOW - START_EPOCH))
REMAINING=$((END_EPOCH - NOW))

PCT=$((ELAPSED * 100 / TOTAL))
[ $PCT -gt 100 ] && PCT=100
[ $PCT -lt 0 ] && PCT=0

if [ $PCT -lt 50 ]; then
  CLASS="claude-low"
elif [ $PCT -lt 80 ]; then
  CLASS="claude-mid"
else
  CLASS="claude-high"
fi

REMAIN_H=$((REMAINING / 3600))
REMAIN_M=$(((REMAINING % 3600) / 60))
COST_FMT=$(LC_NUMERIC=C printf '$%.2f' "$COST")
COST_HR_FMT=$(LC_NUMERIC=C printf '$%.2f' "$COST_HR")
PROJ_FMT=$(LC_NUMERIC=C printf '$%.2f' "$PROJ_COST")
START_FMT=$(date -d "$START" '+%H:%M')
END_FMT=$(date -d "$END" '+%H:%M')

TOOLTIP_STR="Block: ${START_FMT} – ${END_FMT}
${PCT}% used  |  ${REMAIN_H}h ${REMAIN_M}m remaining
Cost: ${COST_FMT} @ ${COST_HR_FMT}/h
Projected: ${PROJ_FMT}
Output tokens: ${OUTPUT_TOK}"

jq -cn \
  --argjson pct "$PCT" \
  --arg tooltip "$TOOLTIP_STR" \
  --arg cls "$CLASS" \
  '{"text": ($pct | tostring), "tooltip": $tooltip, "class": $cls, "percentage": $pct}'
