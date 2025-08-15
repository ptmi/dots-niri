import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

DankModal {
    id: settingsModal

    property bool settingsVisible: false

    signal closingModal()

    onVisibleChanged: {
        if (!visible)
            closingModal();

    }
    // DankModal configuration
    visible: settingsVisible
    width: 650
    height: 750
    keyboardFocus: "ondemand"
    enableShadow: true
    onBackgroundClicked: {
        settingsVisible = false;
    }

    // Keyboard focus and shortcuts
    FocusScope {
        anchors.fill: parent
        focus: settingsModal.settingsVisible
        Keys.onEscapePressed: settingsModal.settingsVisible = false
    }

    content: Component {
        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            // Header
            Row {
                width: parent.width
                spacing: Theme.spacingM

                DankIcon {
                    name: "settings"
                    size: Theme.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Settings"
                    font.pixelSize: Theme.fontSizeXLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - 175 // Spacer to push close button to the right
                    height: 1
                }

                // Close button
                DankActionButton {
                    circular: false
                    iconName: "close"
                    iconSize: Theme.iconSize - 4
                    iconColor: Theme.surfaceText
                    hoverColor: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                    onClicked: settingsModal.settingsVisible = false
                }

            }

            // Settings sections
            ScrollView {
                id: settingsScrollView

                width: parent.width
                height: parent.height - 50
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    id: settingsColumn

                    width: settingsScrollView.width - 20
                    spacing: Theme.spacingL
                    bottomPadding: Theme.spacingL

                    // Profile Settings
                    SettingsSection {
                        title: "Profile"
                        iconName: "person"

                        content: ProfileTab {
                        }

                    }

                    // Clock Settings
                    SettingsSection {
                        title: "Clock & Time"
                        iconName: "schedule"

                        content: ClockTab {
                        }

                    }

                    // Weather Settings
                    SettingsSection {
                        title: "Weather"
                        iconName: "wb_sunny"

                        content: WeatherTab {
                        }

                    }

                    // Widget Visibility Settings
                    SettingsSection {
                        title: "Top Bar Widgets"
                        iconName: "widgets"

                        content: WidgetsTab {
                        }

                    }

                    // Workspace Settings
                    SettingsSection {
                        title: "Workspaces"
                        iconName: "tab"

                        content: WorkspaceTab {
                        }

                    }

                    // Display Settings
                    SettingsSection {
                        title: "Display & Appearance"
                        iconName: "palette"

                        content: DisplayTab {
                        }

                    }

                }

            }

        }

    }

}
