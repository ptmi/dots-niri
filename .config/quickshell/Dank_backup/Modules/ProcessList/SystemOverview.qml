import QtQuick
import qs.Common
import qs.Services

Row {
    width: parent.width
    spacing: Theme.spacingM

    Rectangle {
        width: (parent.width - Theme.spacingM * 2) / 3
        height: 80
        radius: Theme.cornerRadiusLarge
        color: {
            if (ProcessMonitorService.sortBy === "cpu")
                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16);
            else if (cpuCardMouseArea.containsMouse)
                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
            else
                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08);
        }
        border.color: ProcessMonitorService.sortBy === "cpu" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
        border.width: ProcessMonitorService.sortBy === "cpu" ? 2 : 1

        MouseArea {
            id: cpuCardMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ProcessMonitorService.setSortBy("cpu")
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "CPU"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: ProcessMonitorService.sortBy === "cpu" ? Theme.primary : Theme.secondary
                opacity: ProcessMonitorService.sortBy === "cpu" ? 1 : 0.8
            }

            Text {
                text: ProcessMonitorService.totalCpuUsage.toFixed(1) + "%"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            Text {
                text: ProcessMonitorService.cpuCount + " cores"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                opacity: 0.7
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.shortDuration
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.shortDuration
            }

        }

    }

    Rectangle {
        width: (parent.width - Theme.spacingM * 2) / 3
        height: 80
        radius: Theme.cornerRadiusLarge
        color: {
            if (ProcessMonitorService.sortBy === "memory")
                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16);
            else if (memoryCardMouseArea.containsMouse)
                return Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.12);
            else
                return Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08);
        }
        border.color: ProcessMonitorService.sortBy === "memory" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.2)
        border.width: ProcessMonitorService.sortBy === "memory" ? 2 : 1

        MouseArea {
            id: memoryCardMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ProcessMonitorService.setSortBy("memory")
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "Memory"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: ProcessMonitorService.sortBy === "memory" ? Theme.primary : Theme.secondary
                opacity: ProcessMonitorService.sortBy === "memory" ? 1 : 0.8
            }

            Text {
                text: ProcessMonitorService.formatSystemMemory(ProcessMonitorService.usedMemoryKB)
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            Text {
                text: "of " + ProcessMonitorService.formatSystemMemory(ProcessMonitorService.totalMemoryKB)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                opacity: 0.7
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.shortDuration
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.shortDuration
            }

        }

    }

    Rectangle {
        width: (parent.width - Theme.spacingM * 2) / 3
        height: 80
        radius: Theme.cornerRadiusLarge
        color: ProcessMonitorService.totalSwapKB > 0 ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.08) : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04)
        border.color: ProcessMonitorService.totalSwapKB > 0 ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.2) : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.12)
        border.width: 1

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "Swap"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: ProcessMonitorService.totalSwapKB > 0 ? Theme.warning : Theme.surfaceText
                opacity: 0.8
            }

            Text {
                text: ProcessMonitorService.totalSwapKB > 0 ? ProcessMonitorService.formatSystemMemory(ProcessMonitorService.usedSwapKB) : "None"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            Text {
                text: ProcessMonitorService.totalSwapKB > 0 ? "of " + ProcessMonitorService.formatSystemMemory(ProcessMonitorService.totalSwapKB) : "No swap configured"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                opacity: 0.7
            }

        }

    }

}
