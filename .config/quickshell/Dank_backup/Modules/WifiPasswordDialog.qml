import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property bool wifiPasswordDialogVisible: false
    property string wifiPasswordSSID: ""
    property string wifiPasswordInput: ""

    visible: wifiPasswordDialogVisible
    width: 420
    height: 230
    keyboardFocus: "ondemand"
    onVisibleChanged: {
        if (!visible)
            wifiPasswordInput = "";

    }
    onBackgroundClicked: {
        wifiPasswordDialogVisible = false;
        wifiPasswordInput = "";
    }

    // Auto-reopen dialog on invalid password
    Connections {
        function onPasswordDialogShouldReopenChanged() {
            if (WifiService.passwordDialogShouldReopen && WifiService.connectingSSID !== "") {
                wifiPasswordSSID = WifiService.connectingSSID;
                wifiPasswordInput = "";
                wifiPasswordDialogVisible = true;
                WifiService.passwordDialogShouldReopen = false;
            }
        }

        target: WifiService
    }

    content: Component {
        Item {
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingM * 2
                spacing: Theme.spacingM

                // Header
                Row {
                    width: parent.width

                    Column {
                        width: parent.width - 40
                        spacing: Theme.spacingXS

                        Text {
                            text: "Connect to Wi-Fi"
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "Enter password for \"" + wifiPasswordSSID + "\""
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
                            wifiPasswordDialogVisible = false;
                            wifiPasswordInput = "";
                        }
                    }

                }

                // Password input
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)
                    border.color: passwordInput.activeFocus ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                    border.width: passwordInput.activeFocus ? 2 : 1

                    DankTextField {
                        id: passwordInput

                        anchors.fill: parent
                        font.pixelSize: Theme.fontSizeMedium
                        textColor: Theme.surfaceText
                        text: wifiPasswordInput
                        echoMode: showPasswordCheckbox.checked ? TextInput.Normal : TextInput.Password
                        placeholderText: "Enter password"
                        backgroundColor: "transparent"
                        normalBorderColor: "transparent"
                        focusedBorderColor: "transparent"
                        onTextEdited: {
                            wifiPasswordInput = text;
                        }
                        onAccepted: {
                            WifiService.connectToWifiWithPassword(wifiPasswordSSID, passwordInput.text);
                            wifiPasswordDialogVisible = false;
                            wifiPasswordInput = "";
                            passwordInput.text = "";
                        }

                        Connections {
                            function onOpened() {
                                passwordInput.forceActiveFocus();
                            }

                            function onDialogClosed() {
                                passwordInput.clearFocus();
                            }

                            target: root
                        }

                    }

                }

                // Show password checkbox
                Row {
                    spacing: Theme.spacingS

                    Rectangle {
                        id: showPasswordCheckbox

                        property bool checked: false

                        width: 20
                        height: 20
                        radius: 4
                        color: checked ? Theme.primary : "transparent"
                        border.color: checked ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.5)
                        border.width: 2

                        DankIcon {
                            anchors.centerIn: parent
                            name: "check"
                            size: 12
                            color: Theme.background
                            visible: parent.checked
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                showPasswordCheckbox.checked = !showPasswordCheckbox.checked;
                            }
                        }

                    }

                    Text {
                        text: "Show password"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                // Buttons
                Item {
                    width: parent.width
                    height: 40

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingM

                        Rectangle {
                            width: Math.max(70, cancelText.contentWidth + Theme.spacingM * 2)
                            height: 36
                            radius: Theme.cornerRadius
                            color: cancelArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1

                            Text {
                                id: cancelText

                                anchors.centerIn: parent
                                text: "Cancel"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: cancelArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wifiPasswordDialogVisible = false;
                                    wifiPasswordInput = "";
                                }
                            }

                        }

                        Rectangle {
                            width: Math.max(80, connectText.contentWidth + Theme.spacingM * 2)
                            height: 36
                            radius: Theme.cornerRadius
                            color: connectArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                            enabled: passwordInput.text.length > 0
                            opacity: enabled ? 1 : 0.5

                            Text {
                                id: connectText

                                anchors.centerIn: parent
                                text: "Connect"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.background
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: connectArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: {
                                    WifiService.connectToWifiWithPassword(wifiPasswordSSID, passwordInput.text);
                                    wifiPasswordDialogVisible = false;
                                    wifiPasswordInput = "";
                                    passwordInput.text = "";
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

}
