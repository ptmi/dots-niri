#!/bin/bash
# Diagnostic script for Qt/QML environment differences

echo "==== Qt Version ===="
qmake --version 2>/dev/null || qtpaths --qt-version 2>/dev/null || echo "qmake/qtpaths not found"

echo "\n==== Qt Platform Theme ===="
echo "QT_QPA_PLATFORMTHEME: $QT_QPA_PLATFORMTHEME"

echo "\n==== Qt Scale/Font DPI ===="
echo "QT_SCALE_FACTOR: $QT_SCALE_FACTOR"
echo "QT_FONT_DPI: $QT_FONT_DPI"
echo "GDK_SCALE: $GDK_SCALE"
echo "GDK_DPI_SCALE: $GDK_DPI_SCALE"

if command -v xrdb >/dev/null; then
    echo "\n==== X11 DPI (xrdb) ===="
    xrdb -query | grep dpi
fi

echo "\n==== Icon Font Availability (for cross-distro compatibility) ===="
echo "Checking icon fonts used by Quickshell Icon component..."

# Check Material Design Icons
echo -n "Material Symbols Rounded: "
if fc-list | grep -q "Material Symbols Rounded"; then
    echo "✓ FOUND"
    MATERIAL_SYMBOLS_FOUND=1
else
    echo "✗ NOT FOUND"
    MATERIAL_SYMBOLS_FOUND=0
fi

echo -n "Material Icons Round: "
if fc-list | grep -q "Material Icons Round"; then
    echo "✓ FOUND"
    MATERIAL_ICONS_FOUND=1
else
    echo "✗ NOT FOUND"
    MATERIAL_ICONS_FOUND=0
fi

# Check FontAwesome 6
echo -n "Font Awesome 6 Free: "
if fc-list | grep -q "Font Awesome 6 Free"; then
    echo "✓ FOUND"
    FONTAWESOME_FOUND=1
else
    echo "✗ NOT FOUND"
    FONTAWESOME_FOUND=0
fi

# Check JetBrains Mono Nerd Font
echo -n "JetBrainsMono Nerd Font: "
if fc-list | grep -q "JetBrainsMono Nerd Font"; then
    echo "✓ FOUND"
    JETBRAINS_NERD_FOUND=1
else
    echo -n "✗ NOT FOUND, checking JetBrains Mono: "
    if fc-list | grep -q "JetBrains Mono"; then
        echo "✓ FOUND (fallback available)"
        JETBRAINS_FALLBACK_FOUND=1
    else
        echo "✗ NOT FOUND"
        JETBRAINS_FALLBACK_FOUND=0
    fi
fi

echo "\n==== Icon System Recommendation ===="
if [ $MATERIAL_SYMBOLS_FOUND -eq 1 ]; then
    echo "✓ OPTIMAL: Material Symbols Rounded found - best icon experience"
elif [ $MATERIAL_ICONS_FOUND -eq 1 ]; then
    echo "✓ GOOD: Material Icons Round found - good icon experience"
elif [ $FONTAWESOME_FOUND -eq 1 ]; then
    echo "⚠ FAIR: FontAwesome 6 found - acceptable icon experience"
elif [ $JETBRAINS_NERD_FOUND -eq 1 ] || [ $JETBRAINS_FALLBACK_FOUND -eq 1 ]; then
    echo "⚠ BASIC: JetBrains Mono found - basic icon experience"
else
    echo "⚠ FALLBACK: No icon fonts found - will use emoji fallback"
fi

echo "\n==== Font Installation Recommendations ===="
if [ $MATERIAL_SYMBOLS_FOUND -eq 0 ] && [ $MATERIAL_ICONS_FOUND -eq 0 ]; then
    echo "📦 Install Material Design Icons for best experience:"
    echo "   • Ubuntu/Debian: sudo apt install fonts-material-design-icons-iconfont"
    echo "   • Fedora: sudo dnf install google-material-design-icons-fonts"
    echo "   • Arch: sudo pacman -S ttf-material-design-icons"
    echo "   • Or download from: https://fonts.google.com/icons"
fi

if [ $FONTAWESOME_FOUND -eq 0 ]; then
    echo "📦 Install FontAwesome 6 for broader compatibility:"
    echo "   • Ubuntu/Debian: sudo apt install fonts-font-awesome"
    echo "   • Fedora: sudo dnf install fontawesome-fonts"
    echo "   • Arch: sudo pacman -S ttf-font-awesome"
fi

if [ "${JETBRAINS_NERD_FOUND:-0}" -eq 0 ]; then
    echo "📦 Install JetBrains Mono Nerd Font for developer icons:"
    echo "   • Download from: https://github.com/ryanoasis/nerd-fonts/releases"
    echo "   • Or install via package manager if available"
fi

echo "\n==== Quickshell Icon Component Test ===="
if command -v qs >/dev/null 2>&1; then
    echo "Testing Icon component fallback system..."
    # Create a temporary test QML file
    cat > /tmp/icon_test.qml << 'EOF'
import QtQuick
import "../Common"

Item {
    Component.onCompleted: {
        var icon = Qt.createQmlObject('import QtQuick; import "../Common"; Icon { name: "battery"; level: 75; charging: false; available: true }', parent)
        console.log("Icon system detected:", icon.iconSystem)
        console.log("Font family:", icon.font.family)
        console.log("Battery icon:", icon.text)
        Qt.quit()
    }
}
EOF
    
    # Test if we can run the icon test
    if [ -f "../Common/Icon.qml" ]; then
        echo "Running Icon component test..."
        timeout 5s qs -c /tmp/icon_test.qml 2>&1 | grep -E "(Icon system|Font family|Battery icon)" || echo "Icon test failed or timed out"
    else
        echo "Icon.qml not found - make sure you're running from the quickshell directory"
    fi
    
    rm -f /tmp/icon_test.qml
else
    echo "Quickshell (qs) not found - cannot test Icon component"
fi

echo "\n==== All Available Fonts ===="
fc-list : family | sort | uniq | grep -E 'Material|Sans|Serif|Mono|Noto|DejaVu|Roboto|Symbols|Awesome|Nerd' || echo "fc-list not found or no relevant fonts"

echo "\n==== Qt Plugins ===="
QT_DEBUG_PLUGINS=1 qtpaths --plugin-dir 2>&1 | head -20 || echo "qtpaths not found or no plugin info"

echo "\n==== QML Import Paths ===="
qtpaths --qml-imports 2>/dev/null || echo "qtpaths not found"

echo "\n==== System Info ===="
uname -a
cat /etc/os-release

echo "\n==== Graphics Drivers ===="
lspci | grep -i vga || echo "lspci not found"

echo "\n==== Wayland/X11 Session ===="
echo "XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-not set}"
echo "WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-not set}"
echo "DISPLAY: ${DISPLAY:-not set}"

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "✓ Running on Wayland"
else
    echo "✓ Running on X11"
fi

echo "\n==== Qt Environment Variables ===="
echo "QT_QPA_PLATFORM: ${QT_QPA_PLATFORM:-not set}"
echo "QT_WAYLAND_DECORATION: ${QT_WAYLAND_DECORATION:-not set}"
echo "QT_AUTO_SCREEN_SCALE_FACTOR: ${QT_AUTO_SCREEN_SCALE_FACTOR:-not set}"
echo "QT_ENABLE_HIGHDPI_SCALING: ${QT_ENABLE_HIGHDPI_SCALING:-not set}"

echo "\n==== Cross-Distro Compatibility Issues ===="
echo "Checking for common cross-distro problems..."

# Check for common Qt issues
if [ -z "$QT_QPA_PLATFORMTHEME" ]; then
    echo "⚠ QT_QPA_PLATFORMTHEME not set - may cause theme inconsistencies"
fi

# Check for font rendering issues
if [ -z "$FONTCONFIG_PATH" ]; then
    echo "ℹ FONTCONFIG_PATH not set - using system defaults"
fi

# Check for missing libraries that might cause QML issues
echo -n "Checking for essential libraries: "
MISSING_LIBS=""
for lib in libQt6Core.so.6 libQt6Gui.so.6 libQt6Qml.so.6 libQt6Quick.so.6; do
    if ! ldconfig -p | grep -q "$lib"; then
        MISSING_LIBS="$MISSING_LIBS $lib"
    fi
done

if [ -z "$MISSING_LIBS" ]; then
    echo "✓ All essential Qt6 libraries found"
else
    echo "⚠ Missing libraries:$MISSING_LIBS"
    echo "   Install Qt6 development packages for your distro"
fi

echo "\n==== Notification System Check ===="
echo "Checking for common notification issues..."

# Check if notification daemon is running
if pgrep -x "mako" > /dev/null; then
    echo "✓ Mako notification daemon running"
elif pgrep -x "dunst" > /dev/null; then
    echo "✓ Dunst notification daemon running"
elif pgrep -x "swaync" > /dev/null; then
    echo "✓ SwayNC notification daemon running"
else
    echo "⚠ No common notification daemon detected"
fi

# Check D-Bus notification service
if busctl --user status org.freedesktop.Notifications >/dev/null 2>&1; then
    echo "✓ D-Bus notification service available"
else
    echo "⚠ D-Bus notification service not available"
fi

# Check for notification image format issues
echo "ℹ Common notification warnings to expect:"
echo "  - 'Unable to parse pixmap as rowstride is incorrect' - Discord/Telegram images"
echo "  - This is a known issue with some applications sending malformed image data"
echo "  - Does not affect notification functionality, only image display"

echo "\n==== Diagnostic Summary ===="
echo "Run this script on different distros to compare environments."
echo "Save output with: ./qt_env_diagnostics.sh > my_system_info.txt"
echo "Share with developers for troubleshooting cross-distro issues."
echo ""
echo "If you see pixmap rowstride warnings, this is normal for some applications."
echo "The notification system will fall back to app icons or default icons."

# End of diagnostics
