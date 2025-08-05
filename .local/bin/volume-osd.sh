#!/bin/bash
# volume-osd.sh
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep MUTED)

if [[ $MUTED ]]; then
  ICON="󰖁"
else
  if [ "$VOLUME" -lt 34 ]; then ICON="󰕿"
  elif [ "$VOLUME" -lt 67 ]; then ICON="󰖀"
  else ICON="󰕾"; fi
fi

echo "volume;$VOLUME;$ICON" > /tmp/osd.trigger
