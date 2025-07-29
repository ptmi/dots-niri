import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services

Column {
    anchors.fill: parent
    spacing: Theme.spacingM

    function formatNetworkSpeed(bytesPerSec) {
        if (bytesPerSec < 1024)
            return bytesPerSec.toFixed(0) + " B/s";
        else if (bytesPerSec < 1024 * 1024)
            return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        else if (bytesPerSec < 1024 * 1024 * 1024)
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
        else
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " GB/s";
    }

    function formatDiskSpeed(bytesPerSec) {
        if (bytesPerSec < 1024 * 1024)
            return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        else if (bytesPerSec < 1024 * 1024 * 1024)
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
        else
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " GB/s";
    }

    Rectangle {
        width: parent.width
        height: 200
        radius: Theme.cornerRadiusLarge
        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.04)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            Row {
                width: parent.width
                height: 32
                spacing: Theme.spacingM

                Text {
                    text: "CPU"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 80
                    height: 24
                    radius: Theme.cornerRadiusSmall
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: ProcessMonitorService.totalCpuUsage.toFixed(1) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.primary
                        anchors.centerIn: parent
                    }

                }

                Item {
                    width: parent.width - 280
                    height: 1
                }

                Text {
                    text: ProcessMonitorService.cpuCount + " cores"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            ScrollView {
                width: parent.width
                height: parent.height - 40
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: ProcessMonitorService.perCoreCpuUsage.length

                        Row {
                            width: parent.width
                            height: 20
                            spacing: Theme.spacingS

                            Text {
                                text: "C" + index
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 24
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 80
                                height: 6
                                radius: 3
                                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: parent.width * Math.min(1, ProcessMonitorService.perCoreCpuUsage[index] / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: {
                                        const usage = ProcessMonitorService.perCoreCpuUsage[index];
                                        if (usage > 80)
                                            return Theme.error;

                                        if (usage > 60)
                                            return Theme.warning;

                                        return Theme.primary;
                                    }

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: Theme.shortDuration
                                        }

                                    }

                                }

                            }

                            Text {
                                text: ProcessMonitorService.perCoreCpuUsage[index] ? ProcessMonitorService.perCoreCpuUsage[index].toFixed(0) + "%" : "0%"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                width: 32
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                }

            }

        }

    }

    Rectangle {
        width: parent.width
        height: 80
        radius: Theme.cornerRadiusLarge
        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.04)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
        border.width: 1

        Row {
            anchors.centerIn: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "Memory"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Text {
                    text: ProcessMonitorService.formatSystemMemory(ProcessMonitorService.usedMemoryKB) + " / " + ProcessMonitorService.formatSystemMemory(ProcessMonitorService.totalMemoryKB)
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: 200

                Rectangle {
                    width: parent.width
                    height: 16
                    radius: 8
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

                    Rectangle {
                        width: ProcessMonitorService.totalMemoryKB > 0 ? parent.width * (ProcessMonitorService.usedMemoryKB / ProcessMonitorService.totalMemoryKB) : 0
                        height: parent.height
                        radius: parent.radius
                        color: {
                            const usage = ProcessMonitorService.totalMemoryKB > 0 ? (ProcessMonitorService.usedMemoryKB / ProcessMonitorService.totalMemoryKB) : 0;
                            if (usage > 0.9)
                                return Theme.error;

                            if (usage > 0.7)
                                return Theme.warning;

                            return Theme.secondary;
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                            }

                        }

                    }

                }

                Text {
                    text: ProcessMonitorService.totalMemoryKB > 0 ? ((ProcessMonitorService.usedMemoryKB / ProcessMonitorService.totalMemoryKB) * 100).toFixed(1) + "% used" : "No data"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "Swap"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Text {
                    text: ProcessMonitorService.totalSwapKB > 0 ? 
                        ProcessMonitorService.formatSystemMemory(ProcessMonitorService.usedSwapKB) + " / " + ProcessMonitorService.formatSystemMemory(ProcessMonitorService.totalSwapKB) :
                        "No swap configured"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: 200

                Rectangle {
                    width: parent.width
                    height: 16
                    radius: 8
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

                    Rectangle {
                        width: ProcessMonitorService.totalSwapKB > 0 ? parent.width * (ProcessMonitorService.usedSwapKB / ProcessMonitorService.totalSwapKB) : 0
                        height: parent.height
                        radius: parent.radius
                        color: {
                            if (!ProcessMonitorService.totalSwapKB) return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.3);
                            const usage = ProcessMonitorService.usedSwapKB / ProcessMonitorService.totalSwapKB;
                            if (usage > 0.9) return Theme.error;
                            if (usage > 0.7) return Theme.warning; 
                            return Theme.info;
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                            }
                        }
                    }
                }

                Text {
                    text: ProcessMonitorService.totalSwapKB > 0 ? ((ProcessMonitorService.usedSwapKB / ProcessMonitorService.totalSwapKB) * 100).toFixed(1) + "% used" : "Not available"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

            }

        }

    }

    Row {
        width: parent.width
        height: 80
        spacing: Theme.spacingM

        Rectangle {
            width: (parent.width - Theme.spacingM) / 2
            height: 80
            radius: Theme.cornerRadiusLarge
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.04)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                Text {
                    text: "Network"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: Theme.spacingS
                    anchors.horizontalCenter: parent.horizontalCenter

                    Row {
                        spacing: 4

                        Text {
                            text: "↓"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.info
                        }

                        Text {
                            text: formatNetworkSpeed(ProcessMonitorService.networkRxRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                    Row {
                        spacing: 4

                        Text {
                            text: "↑"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.error
                        }

                        Text {
                            text: formatNetworkSpeed(ProcessMonitorService.networkTxRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        Rectangle {
            width: (parent.width - Theme.spacingM) / 2
            height: 80
            radius: Theme.cornerRadiusLarge
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.04)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                Text {
                    text: "Disk"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: Theme.spacingS
                    anchors.horizontalCenter: parent.horizontalCenter

                    Row {
                        spacing: 4

                        Text {
                            text: "R"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primary
                        }

                        Text {
                            text: formatDiskSpeed(ProcessMonitorService.diskReadRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                    Row {
                        spacing: 4

                        Text {
                            text: "W"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.warning
                        }

                        Text {
                            text: formatDiskSpeed(ProcessMonitorService.diskWriteRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

    }

}
