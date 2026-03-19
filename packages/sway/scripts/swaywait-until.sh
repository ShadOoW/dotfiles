#!/bin/sh
# Waits for a window with the given app_id/class to appear, prints its con_id and exits

if [ $# -ne 1 ]
then
    echo "Usage: swaywait-until [app_id/class]"
    exit 1
fi

TARGET=$1

swaymsg -t subscribe -m '["window"]' | while read line
do
    CON=`echo $line | jq -r 'select(.change=="new").container'`
    APPID=`echo $CON | jq -r '.app_id'`
    CLASS=`echo $CON | jq -r '.window_properties.class'`
    CONID=`echo $CON | jq -r '.id'`

    if [ "$APPID" = "$TARGET" ] || [ "$CLASS" = "$TARGET" ]
    then
        echo "$CONID"
        exit 0
    fi
done
