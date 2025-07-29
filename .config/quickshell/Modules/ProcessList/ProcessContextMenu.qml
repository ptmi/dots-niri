
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: processContextMenuWindow

    property var processData: null
    property bool menuVisible: false

    function show(x, y) {
        const menuWidth = 180;
        const menuHeight = menuColumn.implicitHeight + Theme.spacingS * 2;
        const screenWidth = processContextMenuWindow.screen ? processContextMenuWindow.screen.width : 1920;
        const screenHeight = processContextMenuWindow.screen ? processContextMenuWindow.screen.height : 1080;
        let finalX = x;
        let finalY = y;
        if (x + menuWidth > screenWidth - 20)
            finalX = x - menuWidth;

        if (y + menuHeight > screenHeight - 20)
            finalY = y - menuHeight;

        finalX = Math.max(20, finalX);
        finalY = Math.max(20, finalY);
        processContextMenu.x = finalX;
        processContextMenu.y = finalY;
        processContextMenuWindow.menuVisible = true;
    }

    function hide() {
        processContextMenuWindow.menuVisible = false;
    }

    visible: menuVisible
    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Rectangle {
        id: processContextMenu

        width: 180
        height: menuColumn.implicitHeight + Theme.spacingS * 2
        radius: Theme.cornerRadiusLarge
        color: Theme.popupBackground()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        opacity: processContextMenuWindow.menuVisible ? 1 : 0
        scale: processContextMenuWindow.menuVisible ? 1 : 0.85

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

        Column {
            id: menuColumn

            anchors.fill: parent
            anchors.margins: Theme.spacingS
            spacing: 1

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.cornerRadiusSmall
                color: copyPidArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Copy PID"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: copyPidArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (processContextMenuWindow.processData) {
                            copyPidProcess.command = ["wl-copy", processContextMenuWindow.processData.pid.toString()];
                            copyPidProcess.running = true;
                        }
                        processContextMenuWindow.hide();
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }

                }

            }

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.cornerRadiusSmall
                color: copyNameArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Copy Process Name"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: copyNameArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (processContextMenuWindow.processData) {
                            let processName = processContextMenuWindow.processData.displayName || processContextMenuWindow.processData.command;
                            copyNameProcess.command = ["wl-copy", processName];
                            copyNameProcess.running = true;
                        }
                        processContextMenuWindow.hide();
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }

                }

            }

            Rectangle {
                width: parent.width - Theme.spacingS * 2
                height: 5
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 1
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                }

            }

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.cornerRadiusSmall
                color: killArea.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : "transparent"
                enabled: processContextMenuWindow.processData && processContextMenuWindow.processData.pid > 1000
                opacity: enabled ? 1 : 0.5

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Kill Process"
                    font.pixelSize: Theme.fontSizeSmall
                    color: parent.enabled ? (killArea.containsMouse ? Theme.error : Theme.surfaceText) : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: killArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: parent.enabled
                    onClicked: {
                        if (processContextMenuWindow.processData) {
                            killProcess.command = ["kill", processContextMenuWindow.processData.pid.toString()];
                            killProcess.running = true;
                        }
                        processContextMenuWindow.hide();
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }

                }

            }

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.cornerRadiusSmall
                color: forceKillArea.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : "transparent"
                enabled: processContextMenuWindow.processData && processContextMenuWindow.processData.pid > 1000
                opacity: enabled ? 1 : 0.5

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Force Kill Process"
                    font.pixelSize: Theme.fontSizeSmall
                    color: parent.enabled ? (forceKillArea.containsMouse ? Theme.error : Theme.surfaceText) : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                    font.weight: Font.Normal
                }

                MouseArea {
                    id: forceKillArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: parent.enabled
                    onClicked: {
                        if (processContextMenuWindow.processData) {
                            forceKillProcess.command = ["kill", "-9", processContextMenuWindow.processData.pid.toString()];
                            forceKillProcess.running = true;
                        }
                        processContextMenuWindow.hide();
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

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            processContextMenuWindow.menuVisible = false;
        }
    }

    Process {
        id: copyPidProcess

        running: false
    }

    Process {
        id: copyNameProcess

        running: false
    }

    Process {
        id: killProcess

        running: false
    }

    Process {
        id: forceKillProcess

        running: false
    }

}
