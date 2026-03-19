#!/bin/sh

if [ $# -ne 2 ]
then
    echo "Usage: swaywait [app_id/class] [sway_command]"
    exit 1
fi

TARGET=$1
COMMAND=$2

swaymsg -t subscribe -m '["window"]' | while read line
do
    CON=`echo $line | jq -r 'select(.change=="new").container'`
    APPID=`echo $CON | jq -r '.app_id'`
    CLASS=`echo $CON | jq -r '.window_properties.class'`
    CONID=`echo $CON | jq -r '.id'`

    if [ "$APPID" = "$TARGET" ] || [ "$CLASS" = "$TARGET" ]
    then
        swaymsg "[con_id=$CONID] $COMMAND"
        exit 0
    fi
done
