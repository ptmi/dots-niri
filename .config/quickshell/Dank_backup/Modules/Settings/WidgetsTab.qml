import QtQuick
import qs.Common
import qs.Widgets

Column {
    width: parent.width
    spacing: Theme.spacingM

    DankToggle {
        text: "Focused Window"
        description: "Show the currently focused application in the top bar"
        checked: Prefs.showFocusedWindow
        onToggled: (checked) => {
            return Prefs.setShowFocusedWindow(checked);
        }
    }

    DankToggle {
        text: "Weather Widget"
        description: "Display weather information in the top bar"
        checked: Prefs.showWeather
        onToggled: (checked) => {
            return Prefs.setShowWeather(checked);
        }
    }

    DankToggle {
        text: "Media Controls"
        description: "Show currently playing media in the top bar"
        checked: Prefs.showMusic
        onToggled: (checked) => {
            return Prefs.setShowMusic(checked);
        }
    }

    DankToggle {
        text: "Clipboard Button"
        description: "Show clipboard access button in the top bar"
        checked: Prefs.showClipboard
        onToggled: (checked) => {
            return Prefs.setShowClipboard(checked);
        }
    }

    DankToggle {
        text: "System Resources"
        description: "Display CPU and RAM usage indicators"
        checked: Prefs.showSystemResources
        onToggled: (checked) => {
            return Prefs.setShowSystemResources(checked);
        }
    }

    DankToggle {
        text: "System Tray"
        description: "Show system tray icons in the top bar"
        checked: Prefs.showSystemTray
        onToggled: (checked) => {
            return Prefs.setShowSystemTray(checked);
        }
    }

    DankToggle {
        text: "Use OS Logo for App Launcher"
        description: "Display operating system logo instead of apps icon"
        checked: Prefs.useOSLogo
        onToggled: (checked) => {
            return Prefs.setUseOSLogo(checked);
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacingS
        visible: Prefs.useOSLogo

        Item {
            width: parent.width
            height: Theme.spacingS
        }

        Text {
            text: "OS Logo Customization"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            font.weight: Font.Medium
        }

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Text {
                text: "Color Override:"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                width: 90
            }

            DankTextField {
                width: 120
                height: 36
                placeholderText: "#ffffff"
                text: Prefs.osLogoColorOverride
                maximumLength: 7
                font.pixelSize: Theme.fontSizeMedium
                topPadding: Theme.spacingS
                bottomPadding: Theme.spacingS
                onEditingFinished: {
                    var color = text.trim();
                    if (color === "" || /^#[0-9A-Fa-f]{6}$/.test(color))
                        Prefs.setOSLogoColorOverride(color);
                    else
                        text = Prefs.osLogoColorOverride;
                }
            }

        }

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Text {
                text: "Brightness:"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                width: 90
            }

            DankSlider {
                width: 120
                height: 24
                minimum: 0
                maximum: 100
                value: Math.round(Prefs.osLogoBrightness * 100)
                unit: ""
                showValue: false
                onSliderValueChanged: (newValue) => {
                    Prefs.setOSLogoBrightness(newValue / 100);
                }
            }

        }

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Text {
                text: "Contrast:"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                width: 90
            }

            DankSlider {
                width: 120
                height: 24
                minimum: 0
                maximum: 200
                value: Math.round(Prefs.osLogoContrast * 100)
                unit: ""
                showValue: false
                onSliderValueChanged: (newValue) => {
                    Prefs.setOSLogoContrast(newValue / 100);
                }
            }

        }

    }

}
