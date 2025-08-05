#!/bin/bash
# brightness-osd.sh
BRIGHTNESS=$(brightnessctl g)
MAX=$(brightnessctl m)
PERCENT=$(( BRIGHTNESS * 100 / MAX ))

if [ "$PERCENT" -lt 34 ]; then ICON="󰃞"
elif [ "$PERCENT" -lt 67 ]; then ICON="󰃟"
else ICON="󰃠"; fi

echo "brightness;$PERCENT;$ICON" > /tmp/osd.trigger
