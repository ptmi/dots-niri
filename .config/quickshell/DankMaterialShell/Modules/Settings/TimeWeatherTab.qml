import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: timeWeatherTab

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        anchors.bottomMargin: Theme.spacingXL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            // Time Format
            StyledRect {
                width: parent.width
                height: timeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: timeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Time Format"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "24-Hour Format"
                        description: "Use 24-hour time format instead of 12-hour AM/PM"
                        checked: SettingsData.use24HourClock
                        onToggled: (checked) => {
                            return SettingsData.setClockFormat(checked);
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Date Format"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankDropdown {
                            width: parent.width
                            height: 50
                            text: "Top Bar Format"
                            description: "Preview: " + Qt.formatDate(new Date(), SettingsData.clockDateFormat)
                            currentValue: {
                                // Find matching preset or show "Custom"
                                const presets = [{
                                    "format": "ddd d",
                                    "label": "Day Date"
                                }, {
                                    "format": "ddd MMM d",
                                    "label": "Day Month Date"
                                }, {
                                    "format": "MMM d",
                                    "label": "Month Date"
                                }, {
                                    "format": "M/d",
                                    "label": "Numeric (M/D)"
                                }, {
                                    "format": "d/M",
                                    "label": "Numeric (D/M)"
                                }, {
                                    "format": "ddd d MMM yyyy",
                                    "label": "Full with Year"
                                }, {
                                    "format": "yyyy-MM-dd",
                                    "label": "ISO Date"
                                }, {
                                    "format": "dddd, MMMM d",
                                    "label": "Full Day & Month"
                                }];
                                const match = presets.find((p) => {
                                    return p.format === SettingsData.clockDateFormat;
                                });
                                return match ? match.label : "Custom: " + SettingsData.clockDateFormat;
                            }
                            options: ["Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                            onValueChanged: (value) => {
                                const formatMap = {
                                    "Day Date": "ddd d",
                                    "Day Month Date": "ddd MMM d",
                                    "Month Date": "MMM d",
                                    "Numeric (M/D)": "M/d",
                                    "Numeric (D/M)": "d/M",
                                    "Full with Year": "ddd d MMM yyyy",
                                    "ISO Date": "yyyy-MM-dd",
                                    "Full Day & Month": "dddd, MMMM d"
                                };
                                if (value === "Custom...") {
                                    customFormatInput.visible = true;
                                } else {
                                    customFormatInput.visible = false;
                                    SettingsData.setClockDateFormat(formatMap[value]);
                                }
                            }
                        }

                        DankDropdown {
                            width: parent.width
                            height: 50
                            text: "Lock Screen Format"
                            description: "Preview: " + Qt.formatDate(new Date(), SettingsData.lockDateFormat)
                            currentValue: {
                                // Find matching preset or show "Custom"
                                const presets = [{
                                    "format": "ddd d",
                                    "label": "Day Date"
                                }, {
                                    "format": "ddd MMM d",
                                    "label": "Day Month Date"
                                }, {
                                    "format": "MMM d",
                                    "label": "Month Date"
                                }, {
                                    "format": "M/d",
                                    "label": "Numeric (M/D)"
                                }, {
                                    "format": "d/M",
                                    "label": "Numeric (D/M)"
                                }, {
                                    "format": "ddd d MMM yyyy",
                                    "label": "Full with Year"
                                }, {
                                    "format": "yyyy-MM-dd",
                                    "label": "ISO Date"
                                }, {
                                    "format": "dddd, MMMM d",
                                    "label": "Full Day & Month"
                                }];
                                const match = presets.find((p) => {
                                    return p.format === SettingsData.lockDateFormat;
                                });
                                return match ? match.label : "Custom: " + SettingsData.lockDateFormat;
                            }
                            options: ["Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                            onValueChanged: (value) => {
                                const formatMap = {
                                    "Day Date": "ddd d",
                                    "Day Month Date": "ddd MMM d",
                                    "Month Date": "MMM d",
                                    "Numeric (M/D)": "M/d",
                                    "Numeric (D/M)": "d/M",
                                    "Full with Year": "ddd d MMM yyyy",
                                    "ISO Date": "yyyy-MM-dd",
                                    "Full Day & Month": "dddd, MMMM d"
                                };
                                if (value === "Custom...") {
                                    customLockFormatInput.visible = true;
                                } else {
                                    customLockFormatInput.visible = false;
                                    SettingsData.setLockDateFormat(formatMap[value]);
                                }
                            }
                        }

                        DankTextField {
                            id: customFormatInput

                            width: parent.width
                            visible: false
                            placeholderText: "Enter custom top bar format (e.g., ddd MMM d)"
                            text: SettingsData.clockDateFormat
                            onTextChanged: {
                                if (visible && text)
                                    SettingsData.setClockDateFormat(text);
                            }
                        }

                        DankTextField {
                            id: customLockFormatInput

                            width: parent.width
                            visible: false
                            placeholderText: "Enter custom lock screen format (e.g., dddd, MMMM d)"
                            text: SettingsData.lockDateFormat
                            onTextChanged: {
                                if (visible && text)
                                    SettingsData.setLockDateFormat(text);
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: formatHelp.implicitHeight + Theme.spacingM * 2
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                            border.width: 1

                            Column {
                                id: formatHelp

                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Format Legend"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.primary
                                    font.weight: Font.Medium
                                }

                                Row {
                                    spacing: Theme.spacingL

                                    Column {
                                        spacing: 2

                                        StyledText {
                                            text: "• d - Day (1-31)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• dd - Day (01-31)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• ddd - Day name (Mon)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• dddd - Day name (Monday)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }
                                    }

                                    Column {
                                        spacing: 2

                                        StyledText {
                                            text: "• M - Month (1-12)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• MM - Month (01-12)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• MMM - Month (Jan)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• MMMM - Month (January)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }
                                    }

                                    Column {
                                        spacing: 2

                                        StyledText {
                                            text: "• yy - Year (24)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "• yyyy - Year (2024)"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Weather
            StyledRect {
                width: parent.width
                height: weatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: weatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "cloud"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Weather"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Enable Weather"
                        description: "Show weather information in top bar and centcom center"
                        checked: SettingsData.weatherEnabled
                        onToggled: (checked) => {
                            return SettingsData.setWeatherEnabled(checked);
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Fahrenheit"
                        description: "Use Fahrenheit instead of Celsius for temperature"
                        checked: SettingsData.useFahrenheit
                        enabled: SettingsData.weatherEnabled
                        onToggled: (checked) => {
                            return SettingsData.setTemperatureUnit(checked);
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Auto Location"
                        description: "Allow wttr.in to determine location based on IP address"
                        checked: SettingsData.useAutoLocation
                        enabled: SettingsData.weatherEnabled
                        onToggled: (checked) => {
                            return SettingsData.setAutoLocation(checked);
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: !SettingsData.useAutoLocation && SettingsData.weatherEnabled

                        StyledText {
                            text: "Location"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankLocationSearch {
                            width: parent.width
                            currentLocation: SettingsData.weatherLocation
                            placeholderText: "New York, NY"
                            onLocationSelected: (displayName, coordinates) => {
                                SettingsData.setWeatherLocation(displayName, coordinates);
                            }
                        }
                    }
                }
            }

        }

    }


}
