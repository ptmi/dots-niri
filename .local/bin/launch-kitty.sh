#!/bin/bash

SOCKET="unix:/tmp/kitty-rc"

# Check if kitty socket exists and kitty is responsive
if kitty @ --to "$SOCKET" ls &> /dev/null; then
    # Kitty is running with the socket — launch new window remotely
    kitty @ --to "$SOCKET" launch --type=os-window
else
    # No kitty running — start one with the listen-on socket
    kitty --listen-on "$SOCKET" &
fi
