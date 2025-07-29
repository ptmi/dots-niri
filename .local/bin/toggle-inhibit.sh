#!/bin/bash

SERVICE_NAME="swayidle.service"
STATUS_FILE="/tmp/swayidle.status"

if systemctl --user is-active "$SERVICE_NAME"; then
    echo "swayidle is running. Stopping it..."
    systemctl --user stop "$SERVICE_NAME"
    echo "off" > "$STATUS_FILE"
    notify-send "Swayidle" "swayidle stopped. Idle inhibitor disabled." -i system-shutdown
else
    echo "swayidle is not running. Starting it..."
    systemctl --user start "$SERVICE_NAME"
    echo "on" > "$STATUS_FILE"
    notify-send "Swayidle" "swayidle started. Idle inhibitor enabled." -i system-run
fi
