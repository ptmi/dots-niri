import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: ethernetCard
    
    width: parent.width
    height: 80
    radius: Theme.cornerRadius
    color: {
        if (ethernetPreferenceArea.containsMouse && NetworkService.ethernetConnected && NetworkService.wifiEnabled && NetworkService.networkStatus !== "ethernet")
            return Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.8);
        return Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5);
    }
    border.color: NetworkService.networkStatus === "ethernet" ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
    border.width: NetworkService.networkStatus === "ethernet" ? 2 : 1

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: ethernetToggle.left
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingS

        Row {
            spacing: Theme.spacingM

            DankIcon {
                name: "lan"
                size: Theme.iconSize
                color: NetworkService.networkStatus === "ethernet" ? Theme.primary : Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Ethernet"
                font.pixelSize: Theme.fontSizeMedium
                color: NetworkService.networkStatus === "ethernet" ? Theme.primary : Theme.surfaceText
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
            }
        }

        Text {
            text: NetworkService.ethernetConnected ? (NetworkService.ethernetIP || "Connected") : "Disconnected"
            font.pixelSize: Theme.fontSizeSmall
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            leftPadding: Theme.iconSize + Theme.spacingM
            elide: Text.ElideRight
        }
    }

    // Loading spinner for preference changes
    DankIcon {
        id: ethernetLoadingSpinner
        name: "refresh"
        size: Theme.iconSize - 4
        color: Theme.primary
        anchors.right: ethernetToggle.left
        anchors.rightMargin: Theme.spacingS
        anchors.verticalCenter: parent.verticalCenter
        visible: NetworkService.changingPreference && NetworkService.targetPreference === "ethernet"
        z: 10
        
        RotationAnimation {
            target: ethernetLoadingSpinner
            property: "rotation"
            running: ethernetLoadingSpinner.visible
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }

    // Ethernet toggle switch (matching WiFi style)
    DankToggle {
        id: ethernetToggle
        checked: NetworkService.ethernetConnected
        enabled: true
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            NetworkService.toggleNetworkConnection("ethernet");
        }
    }

    // MouseArea for network preference (excluding toggle area)
    MouseArea {
        id: ethernetPreferenceArea
        anchors.fill: parent
        anchors.rightMargin: 60 // Exclude toggle area
        hoverEnabled: true
        cursorShape: (NetworkService.ethernetConnected && NetworkService.wifiEnabled && NetworkService.networkStatus !== "ethernet") ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: NetworkService.ethernetConnected && NetworkService.wifiEnabled && NetworkService.networkStatus !== "ethernet" && !NetworkService.changingNetworkPreference
        onClicked: {
            if (NetworkService.ethernetConnected && NetworkService.wifiEnabled) {
                console.log("Ethernet card clicked for preference");
                if (NetworkService.networkStatus !== "ethernet")
                    NetworkService.setNetworkPreference("ethernet");
                else
                    NetworkService.setNetworkPreference("auto");
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }
}