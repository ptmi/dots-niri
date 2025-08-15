import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common

PanelWindow {
    id: root

    property bool showTrayMenu: false
    property real trayMenuX: 0
    property real trayMenuY: 0
    property var currentTrayMenu: null
    property var currentTrayItem: null

    visible: showTrayMenu
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Rectangle {
        id: menuContainer

        x: trayMenuX
        y: trayMenuY
        width: Math.max(180, Math.min(300, menuList.maxTextWidth + Theme.spacingL * 2))
        height: Math.max(60, menuList.contentHeight + Theme.spacingS * 2)
        color: Theme.popupBackground()
        radius: Theme.cornerRadiusLarge
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        // Material 3 animations
        opacity: showTrayMenu ? 1 : 0
        scale: showTrayMenu ? 1 : 0.85

        // Material 3 drop shadow
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            anchors.bottomMargin: -4
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.15)
            z: parent.z - 1
        }

        Item {
            anchors.fill: parent
            anchors.margins: Theme.spacingS

            QsMenuOpener {
                id: menuOpener

                menu: currentTrayItem && currentTrayItem.hasMenu ? currentTrayItem.menu : null
            }

            // Custom menu styling using ListView
            ListView {
                id: menuList

                // Calculate maximum text width for dynamic menu sizing
                property real maxTextWidth: {
                    let maxWidth = 0;
                    if (model && model.values) {
                        for (let i = 0; i < model.values.length; i++) {
                            const item = model.values[i];
                            if (item && item.text) {
                                const textWidth = textMetrics.advanceWidth * item.text.length * 0.6;
                                maxWidth = Math.max(maxWidth, textWidth);
                            }
                        }
                    }
                    return Math.min(maxWidth, 280); // Cap at reasonable width
                }

                anchors.fill: parent
                spacing: 1
                model: menuOpener.children

                TextMetrics {
                    id: textMetrics

                    font.pixelSize: Theme.fontSizeSmall
                    text: "M"
                }

                delegate: Rectangle {
                    width: ListView.view.width
                    height: modelData.isSeparator ? 5 : 28
                    radius: modelData.isSeparator ? 0 : Theme.cornerRadiusSmall
                    color: modelData.isSeparator ? "transparent" : (menuItemArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent")

                    // Separator line
                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingS * 2
                        height: 1
                        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    }

                    // Menu item content
                    Row {
                        visible: !modelData.isSeparator
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXS

                        Text {
                            text: modelData.text || ""
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Normal
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                    }

                    MouseArea {
                        id: menuItemArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: modelData.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                        enabled: !modelData.isSeparator
                        onClicked: {
                            if (modelData.triggered)
                                modelData.triggered();

                            showTrayMenu = false;
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }

                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            showTrayMenu = false;
        }
    }

}
