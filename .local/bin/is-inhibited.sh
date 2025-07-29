#!/bin/bash

# Assuming your toggle script uses a status file:
STATUS_FILE="/tmp/swayidle.status"

if [[ -f "$STATUS_FILE" && "$(cat "$STATUS_FILE")" == "on" ]]; then
    exit 0  # inhibitor is ON
else
    exit 1  # inhibitor is OFF
fi
