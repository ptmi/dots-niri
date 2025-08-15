import "."
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: ramWidget

    property bool showPercentage: true
    property bool showIcon: true

    width: 55
    height: 30
    radius: Theme.cornerRadius
    color: ramArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08)

    MouseArea {
        id: ramArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ProcessMonitorService.setSortBy("memory");
            processListDropdown.toggle();
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        // RAM icon
        DankIcon {
            name: "developer_board" // Material Design CPU/processor icon (swapped from CPU widget)
            size: Theme.iconSize - 8
            color: {
                if (SystemMonitorService.memoryUsage > 90)
                    return Theme.error;

                if (SystemMonitorService.memoryUsage > 75)
                    return Theme.warning;

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        // Percentage text
        Text {
            text: (SystemMonitorService.memoryUsage || 0).toFixed(0) + "%"
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
