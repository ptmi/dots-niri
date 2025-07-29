import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets

Column {
    id: root

    width: parent.width
    spacing: Theme.spacingL

    DankToggle {
        text: "Night Mode"
        description: "Apply warm color temperature to reduce eye strain"
        checked: Prefs.nightModeEnabled
        onToggled: (checked) => {
            Prefs.setNightModeEnabled(checked);
            if (checked)
                nightModeEnableProcess.running = true;
            else
                nightModeDisableProcess.running = true;
        }
    }

    DankToggle {
        text: "Light Mode"
        description: "Use light theme instead of dark theme"
        checked: Prefs.isLightMode
        onToggled: (checked) => {
            Prefs.setLightMode(checked);
            Theme.isLightMode = checked;
        }
    }

    DankDropdown {
        text: "Icon Theme"
        description: "Select icon theme (requires restart)"
        currentValue: Prefs.iconTheme
        options: Prefs.availableIconThemes
        onValueChanged: (value) => {
            Prefs.setIconTheme(value);
        }
    }

    // Top Bar Transparency
    Column {
        width: parent.width
        spacing: Theme.spacingS

        Text {
            text: "Top Bar Transparency"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            font.weight: Font.Medium
        }

        DankSlider {
            width: parent.width
            value: Math.round(Prefs.topBarTransparency * 100)
            minimum: 0
            maximum: 100
            leftIcon: "opacity"
            rightIcon: "circle"
            unit: "%"
            showValue: true
            onSliderDragFinished: (finalValue) => {
                let transparencyValue = finalValue / 100;
                Prefs.setTopBarTransparency(transparencyValue);
            }
        }

        Text {
            text: "Adjust the transparency of the top bar background"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
            width: parent.width
        }

    }

    // Popup Transparency
    Column {
        width: parent.width
        spacing: Theme.spacingS

        Text {
            text: "Popup Transparency"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            font.weight: Font.Medium
        }

        DankSlider {
            width: parent.width
            value: Math.round(Prefs.popupTransparency * 100)
            minimum: 0
            maximum: 100
            leftIcon: "blur_on"
            rightIcon: "circle"
            unit: "%"
            showValue: true
            onSliderDragFinished: (finalValue) => {
                let transparencyValue = finalValue / 100;
                Prefs.setPopupTransparency(transparencyValue);
            }
        }

        Text {
            text: "Adjust transparency for dialogs, menus, and popups"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
            width: parent.width
        }

    }

    // Theme Picker
    Column {
        width: parent.width
        spacing: Theme.spacingS

        Text {
            text: "Theme Color"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            font.weight: Font.Medium
        }

        ThemePicker {
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    // Night mode processes
    Process {
        id: nightModeEnableProcess

        command: ["bash", "-c", "if command -v wlsunset > /dev/null; then pkill wlsunset; wlsunset -t 3000 & elif command -v redshift > /dev/null; then pkill redshift; redshift -P -O 3000 & else echo 'No night mode tool available'; fi"]
        running: false
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                console.warn("Failed to enable night mode");
                Prefs.setNightModeEnabled(false);
            }
        }
    }

    Process {
        id: nightModeDisableProcess

        command: ["bash", "-c", "pkill wlsunset; pkill redshift; if command -v wlsunset > /dev/null; then wlsunset -t 6500 -T 6500 & sleep 1; pkill wlsunset; elif command -v redshift > /dev/null; then redshift -P -O 6500; redshift -x; fi"]
        running: false
        onExited: (exitCode) => {
            if (exitCode !== 0)
                console.warn("Failed to disable night mode");

        }
    }

}
