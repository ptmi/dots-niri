import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Column {
    id: root
    
    property var bluetoothContextMenuWindow
    
    width: parent.width
    spacing: Theme.spacingM
    visible: BluetoothService.adapter && BluetoothService.adapter.enabled

    Text {
        text: "Paired Devices"
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.surfaceText
        font.weight: Font.Medium
    }

    Repeater {
        model: BluetoothService.adapter && BluetoothService.adapter.devices ? BluetoothService.adapter.devices.values.filter((dev) => {
            return dev && (dev.paired || dev.trusted);
        }) : []

        Rectangle {
            width: parent.width
            height: 60
            radius: Theme.cornerRadius
            color: btDeviceArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : (modelData.connected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08))
            border.color: modelData.connected ? Theme.primary : "transparent"
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingM

                DankIcon {
                    name: BluetoothService.getDeviceIcon(modelData)
                    size: Theme.iconSize
                    color: modelData.connected ? Theme.primary : Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: modelData.name || modelData.deviceName
                        font.pixelSize: Theme.fontSizeMedium
                        color: modelData.connected ? Theme.primary : Theme.surfaceText
                        font.weight: modelData.connected ? Font.Medium : Font.Normal
                    }

                    Row {
                        spacing: Theme.spacingXS

                        Text {
                            text: BluetoothDeviceState.toString(modelData.state)
                            font.pixelSize: Theme.fontSizeSmall
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                        }

                        Text {
                            text: {
                                if (modelData.batteryAvailable && modelData.battery > 0)
                                    return "• " + Math.round(modelData.battery * 100) + "%";

                                var btBattery = BatteryService.bluetoothDevices.find((dev) => {
                                    return dev.name === (modelData.name || modelData.deviceName) || dev.name.toLowerCase().includes((modelData.name || modelData.deviceName).toLowerCase()) || (modelData.name || modelData.deviceName).toLowerCase().includes(dev.name.toLowerCase());
                                });
                                return btBattery ? "• " + btBattery.percentage + "%" : "";
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            visible: text.length > 0
                        }
                    }
                }
            }

            Rectangle {
                id: btMenuButton

                width: 32
                height: 32
                radius: Theme.cornerRadius
                color: btMenuButtonArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter

                DankIcon {
                    name: "more_vert"
                    size: Theme.iconSize
                    color: Theme.surfaceText
                    opacity: 0.6
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: btMenuButtonArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (bluetoothContextMenuWindow) {
                            bluetoothContextMenuWindow.deviceData = modelData;
                            let localPos = btMenuButtonArea.mapToItem(bluetoothContextMenuWindow.parentItem, btMenuButtonArea.width / 2, btMenuButtonArea.height);
                            bluetoothContextMenuWindow.show(localPos.x, localPos.y);
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                    }
                }
            }

            MouseArea {
                id: btDeviceArea

                anchors.fill: parent
                anchors.rightMargin: 40
                hoverEnabled: true
                enabled: !BluetoothService.isDeviceBusy(modelData)
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.BusyCursor
                onClicked: {
                    if (modelData.connected) {
                        modelData.disconnect();
                    } else {
                        BluetoothService.connectDeviceWithTrust(modelData);
                    }
                }
            }
        }
    }
}