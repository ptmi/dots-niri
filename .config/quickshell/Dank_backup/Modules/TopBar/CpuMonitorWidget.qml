import "."
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: cpuWidget

    property bool showPercentage: true
    property bool showIcon: true

    width: 55
    height: 30
    radius: Theme.cornerRadius
    color: cpuArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08)

    MouseArea {
        id: cpuArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ProcessMonitorService.setSortBy("cpu");
            processListDropdown.toggle();
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        // CPU icon
        DankIcon {
            name: "memory" // Material Design memory icon (swapped from RAM widget)
            size: Theme.iconSize - 8
            color: {
                if (SystemMonitorService.cpuUsage > 80)
                    return Theme.error;

                if (SystemMonitorService.cpuUsage > 60)
                    return Theme.warning;

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        // Percentage text
        Text {
            text: (SystemMonitorService.cpuUsage || 0).toFixed(0) + "%"
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
