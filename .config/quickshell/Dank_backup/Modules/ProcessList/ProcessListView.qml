import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services

Column {
    id: root
    property var processContextMenuWindow: null
    property var contextMenu: null

    Item {
        id: columnHeaders

        width: parent.width
        anchors.leftMargin: 8
        height: 24

        Text {
            text: "Process"
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            opacity: 0.7
            anchors.left: parent.left
            anchors.leftMargin: 0 // Left align with content area
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 80
            height: 20
            color: "transparent"
            anchors.right: parent.right
            anchors.rightMargin: 200 // Slight adjustment to move right
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "CPU"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                opacity: 0.7
                anchors.centerIn: parent
            }

        }

        Rectangle {
            width: 80
            height: 20
            color: "transparent"
            anchors.right: parent.right
            anchors.rightMargin: 112 // Move right by decreasing rightMargin
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "RAM"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                opacity: 0.7
                anchors.centerIn: parent
            }

        }

        Text {
            text: "PID"
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            opacity: 0.7
            width: 50
            horizontalAlignment: Text.AlignRight
            anchors.right: parent.right
            anchors.rightMargin: 53 // Move left by increasing rightMargin
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 28
            height: 28
            radius: Theme.cornerRadius
            color: sortOrderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: ProcessMonitorService.sortDescending ? "↓" : "↑"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.centerIn: parent
            }

            MouseArea {
                id: sortOrderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ProcessMonitorService.toggleSortOrder()
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

    }

    ScrollView {
        width: parent.width
        height: parent.height - 24 // Subtract header height
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: processListView

            anchors.fill: parent
            model: ProcessMonitorService.processes
            spacing: 4

            delegate: ProcessListItem {
                process: modelData
                contextMenu: root.contextMenu
                processContextMenuWindow: root.contextMenu
            }
        }
    }
}
