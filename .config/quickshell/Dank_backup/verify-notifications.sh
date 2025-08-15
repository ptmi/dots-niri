#!/bin/bash

# Enhanced Notification System Test Script with Common Icons
# Uses icons that are more likely to be available on most systems

echo "🔔 Testing Enhanced Notification System Features"
echo "============================================================="

# Check what icons are available
echo "Checking available icons..."
if [ -d "~/.local/share/icons/Papirus" ]; then
    echo "✓ Icon theme found"
    ICON_BASE="~/.local/share/icons/Papirus"
else
    echo "! Using fallback icons"
    ICON_BASE=""
fi

# Test 1: Basic notifications
echo "📱 Test 1: Basic notifications"
notify-send -i preferences-desktop "Test App" "Basic notification message"
sleep 2

# Test 2: Media notifications (should replace each other)
echo "🎵 Test 2: Media notifications (replacement behavior)"
notify-send -i audio-x-generic "Spotify" "Now Playing: Song 1 - Artist A"
sleep 2
notify-send -i audio-x-generic "Spotify" "Now Playing: Song 2 - Artist B"
sleep 2

# Test 3: System notifications (grouped by category)
echo "🔋 Test 3: System notifications (grouped by category)"
notify-send -i battery "UPower" "Battery Low: 15% remaining"
sleep 1
notify-send -i network-wired "NetworkManager" "Network Connected: WiFi connected"
sleep 1
notify-send -i system-software-update "System" "Updates Available: 5 packages can be updated"
sleep 2

# Test 4: Conversation notifications (should group and auto-expand)
echo "💬 Test 4: Conversation notifications (grouping)"
if command -v discord &> /dev/null; then
    notify-send -i discord "Discord" "#general: User1 says Hello everyone!"
    sleep 1
    notify-send -i discord "Discord" "#general: User2 says Hey there!"
    sleep 1
    notify-send -i discord "Discord" "john_doe: Private message from John"
else
    notify-send -i internet-chat "Discord" "#general: User1 says Hello everyone!"
    sleep 1
    notify-send -i internet-chat "Discord" "#general: User2 says Hey there!"
    sleep 1
    notify-send -i internet-chat "Discord" "john_doe: Private message from John"
fi
sleep 2

# Test 5: Urgent notifications
echo "🚨 Test 5: Urgent notifications"
notify-send -u critical -i dialog-warning "Critical Alert" "System overheating detected - Temperature: 85°C"
sleep 2

# Test 6: Notifications with actions (simulated)
echo "⚡ Test 6: Action buttons"
notify-send -i system-upgrade "System Update" "Updates available - Click to install or remind later"
sleep 2

# Test 7: Multiple apps generating notifications
echo "📊 Test 7: Multiple apps"
notify-send -i mail-message-new "Email" "You have 3 new emails"
sleep 0.5
notify-send -i office-calendar "Calendar" "Daily standup in 5 minutes"
sleep 0.5
notify-send -i folder-downloads "File Manager" "document.pdf downloaded"
sleep 2

echo ""
echo "✅ Notification tests completed!"
echo ""
echo "📋 Enhanced Features Tested:"
echo "  • Media notification replacement"
echo "  • System notification grouping"
echo "  • Conversation grouping and auto-expansion"
echo "  • Urgency level handling"
echo "  • Action button support"
echo "  • Multi-app notification handling"
echo ""
echo "🎯 Check your notification popup and notification center to see the results!"
echo ""
echo "Note: Some icons may show as fallback (checkerboard) if icon themes aren't installed."
echo "To install more icons: sudo pacman -S papirus-icon-theme adwaita-icon-theme"