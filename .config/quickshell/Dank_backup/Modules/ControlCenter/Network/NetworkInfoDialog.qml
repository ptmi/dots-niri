import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property bool networkInfoDialogVisible: false
    property string networkSSID: ""
    property var networkData: null
    property string networkDetails: ""

    function showNetworkInfo(ssid, data) {
        networkSSID = ssid;
        networkData = data;
        networkInfoDialogVisible = true;
        WifiService.fetchNetworkInfo(ssid);
    }

    function hideDialog() {
        networkInfoDialogVisible = false;
        networkSSID = "";
        networkData = null;
        networkDetails = "";
    }

    visible: networkInfoDialogVisible
    width: 600
    height: 500
    enableShadow: true
    onBackgroundClicked: {
        hideDialog();
    }
    onVisibleChanged: {
        if (!visible) {
            networkSSID = "";
            networkData = null;
            networkDetails = "";
        }
    }

    content: Component {
        Item {
            anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingL

            // Header
            Row {
                width: parent.width

                Column {
                    width: parent.width - 40
                    spacing: Theme.spacingXS

                    Text {
                        text: "Network Information"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    Text {
                        text: "Details for \"" + networkSSID + "\""
                        font.pixelSize: Theme.fontSizeMedium
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                        width: parent.width
                        elide: Text.ElideRight
                    }

                }

                DankActionButton {
                    iconName: "close"
                    iconSize: Theme.iconSize - 4
                    iconColor: Theme.surfaceText
                    hoverColor: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                    onClicked: {
                        root.hideDialog();
                    }
                }

            }

            // Network Details
            ScrollView {
                width: parent.width
                height: parent.height - 140
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Flickable {
                    contentWidth: parent.width
                    contentHeight: detailsRect.height

                    Rectangle {
                        id: detailsRect

                        width: parent.width
                        height: Math.max(parent.parent.height, detailsText.contentHeight + Theme.spacingM * 2)
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                        border.width: 1

                        Text {
                            id: detailsText

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            text: WifiService.networkInfoDetails.replace(/\\n/g, '\n') || "No information available"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }

                    }

                }

            }

            // Close Button
            Item {
                width: parent.width
                height: 40

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(70, closeText.contentWidth + Theme.spacingM * 2)
                    height: 36
                    radius: Theme.cornerRadius
                    color: closeArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary

                    Text {
                        id: closeText

                        anchors.centerIn: parent
                        text: "Close"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.background
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: closeArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.hideDialog();
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

        }
        }
    }

}
