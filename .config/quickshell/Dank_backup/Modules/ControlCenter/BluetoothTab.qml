import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Bluetooth

Item {
    id: bluetoothTab

    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: parent.width
            spacing: Theme.spacingL

            BluetoothToggle { }

            PairedDevicesList {
                bluetoothContextMenuWindow: bluetoothContextMenuWindow
            }

            AvailableDevicesList { }
        }
    }

    BluetoothContextMenu {
        id: bluetoothContextMenuWindow
        parentItem: bluetoothTab
    }

    MouseArea {
        anchors.fill: parent
        visible: bluetoothContextMenuWindow.visible
        onClicked: {
            bluetoothContextMenuWindow.hide();
        }

        MouseArea {
            x: bluetoothContextMenuWindow.x
            y: bluetoothContextMenuWindow.y
            width: bluetoothContextMenuWindow.width
            height: bluetoothContextMenuWindow.height
            onClicked: {
            }
        }
    }
}