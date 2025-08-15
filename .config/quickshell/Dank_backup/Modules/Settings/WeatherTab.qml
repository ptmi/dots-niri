import QtQuick
import qs.Common
import qs.Widgets

Column {
    width: parent.width
    spacing: Theme.spacingM

    DankToggle {
        text: "Fahrenheit"
        description: "Use Fahrenheit instead of Celsius for temperature"
        checked: Prefs.useFahrenheit
        onToggled: (checked) => {
            return Prefs.setTemperatureUnit(checked);
        }
    }

    // Weather Location Override
    Column {
        width: parent.width
        spacing: Theme.spacingM

        DankToggle {
            text: "Override Location"
            description: "Use a specific location instead of auto-detection"
            checked: Prefs.weatherLocationOverrideEnabled
            onToggled: (checked) => {
                return Prefs.setWeatherLocationOverrideEnabled(checked);
            }
        }

        // Location input - only visible when override is enabled
        Column {
            width: parent.width
            spacing: Theme.spacingS
            visible: Prefs.weatherLocationOverrideEnabled
            opacity: visible ? 1 : 0

            Text {
                text: "Location"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            DankLocationSearch {
                width: parent.width
                currentLocation: Prefs.weatherLocationOverride
                placeholderText: "Search for a location..."
                onLocationSelected: (displayName, coordinates) => {
                    Prefs.setWeatherLocationOverride(coordinates);
                }
            }

            Text {
                text: "Examples: \"New York\", \"Tokyo\", \"44511\""
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.mediumDuration
                    easing.type: Theme.emphasizedEasing
                }

            }

        }

    }

}
