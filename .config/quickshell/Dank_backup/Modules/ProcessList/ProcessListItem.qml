import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: processItem

    property var process: null
    property var contextMenu: null
    property var processContextMenuWindow: null

    width: parent.width
    height: 40
    radius: Theme.cornerRadiusLarge
    color: processMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : "transparent"
    border.color: processMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
    border.width: 1

    MouseArea {
        id: processMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (process && process.pid > 0 && contextMenu) {
                    contextMenu.processData = process;
                    let globalPos = processMouseArea.mapToGlobal(mouse.x, mouse.y);
                    contextMenu.show(globalPos.x, globalPos.y);
                }
            }
        }
        onPressAndHold: {
            if (process && process.pid > 0 && processContextMenuWindow) {
                processContextMenuWindow.processData = process;
                let globalPos = processMouseArea.mapToGlobal(processMouseArea.width / 2, processMouseArea.height / 2);
                processContextMenuWindow.show(globalPos.x, globalPos.y);
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 8

        DankIcon {
            id: processIcon

            name: ProcessMonitorService.getProcessIcon(process ? process.command : "")
            size: Theme.iconSize - 4
            color: {
                if (process && process.cpu > 80)
                    return Theme.error;

                if (process && process.cpu > 50)
                    return Theme.warning;

                return Theme.surfaceText;
            }
            opacity: 0.8
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: process ? process.displayName : ""
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            width: 250
            elide: Text.ElideRight
            anchors.left: processIcon.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: cpuBadge

            width: 80
            height: 20
            radius: Theme.cornerRadius
            color: {
                if (process && process.cpu > 80)
                    return Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12);

                if (process && process.cpu > 50)
                    return Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12);

                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08);
            }
            anchors.right: parent.right
            anchors.rightMargin: 194
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: ProcessMonitorService.formatCpuUsage(process ? process.cpu : 0)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
                color: {
                    if (process && process.cpu > 80)
                        return Theme.error;

                    if (process && process.cpu > 50)
                        return Theme.warning;

                    return Theme.surfaceText;
                }
                anchors.centerIn: parent
            }

        }

        Rectangle {
            id: memoryBadge

            width: 80
            height: 20
            radius: Theme.cornerRadius
            color: {
                if (process && process.memoryKB > 1024 * 1024)
                    return Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12);

                if (process && process.memoryKB > 512 * 1024)
                    return Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12);

                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08);
            }
            anchors.right: parent.right
            anchors.rightMargin: 102
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: ProcessMonitorService.formatMemoryUsage(process ? process.memoryKB : 0)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
                color: {
                    if (process && process.memoryKB > 1024 * 1024)
                        return Theme.error;

                        if (process && process.memoryKB > 512 * 1024)
                        return Theme.warning;

                        return Theme.surfaceText;
                }
                anchors.centerIn: parent
            }

        }

        Text {
            text: process ? process.pid.toString() : ""
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            opacity: 0.7
            width: 50
            horizontalAlignment: Text.AlignRight
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: menuButton

            width: 28
            height: 28
            radius: Theme.cornerRadius
            color: menuButtonArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            DankIcon {
                name: "more_vert"
                size: Theme.iconSize - 2
                color: Theme.surfaceText
                opacity: 0.6
                anchors.centerIn: parent
            }

            MouseArea {
                id: menuButtonArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (process && process.pid > 0 && processContextMenuWindow) {
                        processContextMenuWindow.processData = process;
                        let globalPos = menuButtonArea.mapToGlobal(menuButtonArea.width / 2, menuButtonArea.height);
                        processContextMenuWindow.show(globalPos.x, globalPos.y);
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

    }

}
