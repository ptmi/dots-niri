import "../../Widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property bool controlCenterVisible: false
    property string currentTab: "network" // "network", "audio", "bluetooth", "display"
    property bool powerOptionsExpanded: false

    signal powerActionRequested(string action, string title, string message)

    visible: controlCenterVisible
    onVisibleChanged: {
        // Enable/disable WiFi auto-refresh based on control center visibility
        WifiService.autoRefreshEnabled = visible && NetworkService.wifiEnabled;
        // Stop bluetooth scanning when control center is closed
        if (!visible && BluetoothService.adapter && BluetoothService.adapter.discovering)
            BluetoothService.adapter.discovering = false;

        // Refresh uptime when opened
        if (visible && UserInfoService)
            UserInfoService.getUptime();

    }
    implicitWidth: 600
    implicitHeight: 500
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Rectangle {
        width: Math.min(600, Screen.width - Theme.spacingL * 2)
        height: root.powerOptionsExpanded ? 570 : 500
        x: Math.max(Theme.spacingL, Screen.width - width - Theme.spacingL)
        y: Theme.barHeight + Theme.spacingXS
        color: Theme.popupBackground()
        radius: Theme.cornerRadiusLarge
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        opacity: controlCenterVisible ? 1 : 0
        // TopBar dropdown animation - optimized for performance
        transform: [
            Scale {
                id: scaleTransform

                origin.x: 600 // Use fixed width since popup is max 600px wide
                origin.y: 0
                xScale: controlCenterVisible ? 1 : 0.95
                yScale: controlCenterVisible ? 1 : 0.8
            },
            Translate {
                id: translateTransform

                x: controlCenterVisible ? 0 : 15 // Slide slightly left when hidden
                y: controlCenterVisible ? 0 : -30
            }
        ]
        // Single coordinated animation for better performance
        states: [
            State {
                name: "visible"
                when: controlCenterVisible

                PropertyChanges {
                    target: scaleTransform
                    xScale: 1
                    yScale: 1
                }

                PropertyChanges {
                    target: translateTransform
                    x: 0
                    y: 0
                }

            },
            State {
                name: "hidden"
                when: !controlCenterVisible

                PropertyChanges {
                    target: scaleTransform
                    xScale: 0.95
                    yScale: 0.8
                }

                PropertyChanges {
                    target: translateTransform
                    x: 15
                    y: -30
                }

            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "*"

                ParallelAnimation {
                    NumberAnimation {
                        targets: [scaleTransform, translateTransform]
                        properties: "xScale,yScale,x,y"
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

            }
        ]

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            // Elegant User Header
            Column {
                width: parent.width
                spacing: Theme.spacingL

                Rectangle {
                    width: parent.width
                    height: 90
                    radius: Theme.cornerRadiusLarge
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.4)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingL
                        anchors.rightMargin: Theme.spacingL
                        spacing: Theme.spacingL

                        // Profile Picture Container
                        Item {
                            id: avatarContainer

                            property bool hasImage: profileImageLoader.status === Image.Ready

                            width: 64
                            height: 64

                            // This rectangle provides the themed ring via its border.
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.color: Theme.primary
                                border.width: 1 // The ring is 1px thick.
                                visible: parent.hasImage
                            }

                            // Hidden Image loader. Its only purpose is to load the texture.
                            Image {
                                id: profileImageLoader

                                source: {
                                    if (Prefs.profileImage === "")
                                        return "";

                                    if (Prefs.profileImage.startsWith("/"))
                                        return "file://" + Prefs.profileImage;

                                    return Prefs.profileImage;
                                }
                                smooth: true
                                asynchronous: true
                                mipmap: true
                                cache: true
                                visible: false // This item is never shown directly.
                            }

                            MultiEffect {
                                anchors.fill: parent
                                anchors.margins: 5
                                source: profileImageLoader
                                maskEnabled: true
                                maskSource: circularMask
                                visible: avatarContainer.hasImage
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1
                            }

                            Item {
                                id: circularMask

                                width: 64 - 10
                                height: 64 - 10
                                layer.enabled: true
                                layer.smooth: true
                                visible: false

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "black"
                                    antialiasing: true
                                }

                            }

                            // Fallback for when there is no image.
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Theme.primary
                                visible: !parent.hasImage

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "person"
                                    size: Theme.iconSize + 8
                                    color: Theme.primaryText
                                }

                            }

                            // Error icon for when the image fails to load.
                            DankIcon {
                                anchors.centerIn: parent
                                name: "warning"
                                size: Theme.iconSize + 8
                                color: Theme.primaryText
                                visible: Prefs.profileImage !== "" && profileImageLoader.status === Image.Error
                            }

                        }

                        // User Info Text
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS

                            Text {
                                text: UserInfoService.fullName || UserInfoService.username || "User"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "Uptime: " + (UserInfoService.uptime || "Unknown")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                font.weight: Font.Normal
                            }

                        }

                    }

                    // Action Buttons - Power and Settings
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Theme.spacingL
                        spacing: Theme.spacingS

                        // Power Button
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: powerButton.containsMouse || root.powerOptionsExpanded ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                radius: parent.radius
                                color: "transparent"
                                clip: true

                                DankIcon {
                                    id: dankIcon

                                    anchors.centerIn: parent
                                    name: root.powerOptionsExpanded ? "expand_less" : "power_settings_new"
                                    size: Theme.iconSize - 2
                                    color: powerButton.containsMouse || root.powerOptionsExpanded ? Theme.error : Theme.surfaceText

                                    Behavior on name {
                                        // Smooth icon transition
                                        SequentialAnimation {
                                            NumberAnimation {
                                                target: dankIcon
                                                property: "opacity"
                                                to: 0
                                                duration: Theme.shortDuration / 2
                                                easing.type: Theme.standardEasing
                                            }

                                            PropertyAction {
                                                target: dankIcon
                                                property: "name"
                                            }

                                            NumberAnimation {
                                                target: dankIcon
                                                property: "opacity"
                                                to: 1
                                                duration: Theme.shortDuration / 2
                                                easing.type: Theme.standardEasing
                                            }

                                        }

                                    }

                                }

                            }

                            MouseArea {
                                id: powerButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerOptionsExpanded = !root.powerOptionsExpanded;
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }

                            }

                        }

                        // Settings Button
                        DankActionButton {
                            buttonSize: 40
                            iconName: "settings"
                            iconSize: Theme.iconSize - 2
                            iconColor: Theme.surfaceText
                            backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                            hoverColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            onClicked: {
                                controlCenterVisible = false;
                                settingsModal.settingsVisible = true;
                            }
                        }

                    }

                }

                // Animated Collapsible Power Options (optimized)
                Rectangle {
                    width: parent.width
                    height: root.powerOptionsExpanded ? 60 : 0
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.4)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: root.powerOptionsExpanded ? 1 : 0
                    opacity: root.powerOptionsExpanded ? 1 : 0
                    clip: true

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingL
                        visible: root.powerOptionsExpanded

                        // Logout
                        Rectangle {
                            width: 100
                            height: 34
                            radius: Theme.cornerRadius
                            color: logoutButton.containsMouse ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "logout"
                                    size: Theme.fontSizeSmall
                                    color: logoutButton.containsMouse ? Theme.warning : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Logout"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: logoutButton.containsMouse ? Theme.warning : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                id: logoutButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerOptionsExpanded = false;
                                    root.powerActionRequested("logout", "Logout", "Are you sure you want to logout?");
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }

                            }

                        }

                        // Reboot
                        Rectangle {
                            width: 100
                            height: 34
                            radius: Theme.cornerRadius
                            color: rebootButton.containsMouse ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "restart_alt"
                                    size: Theme.fontSizeSmall
                                    color: rebootButton.containsMouse ? Theme.warning : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Restart"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: rebootButton.containsMouse ? Theme.warning : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                id: rebootButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerOptionsExpanded = false;
                                    root.powerActionRequested("reboot", "Restart", "Are you sure you want to restart?");
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }

                            }

                        }

                        // Suspend
                        Rectangle {
                            width: 100
                            height: 34
                            radius: Theme.cornerRadius
                            color: suspendButton.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "bedtime"
                                    size: Theme.fontSizeSmall
                                    color: suspendButton.containsMouse ? Theme.primary : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Suspend"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: suspendButton.containsMouse ? Theme.primary : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                id: suspendButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerOptionsExpanded = false;
                                    root.powerActionRequested("suspend", "Suspend", "Are you sure you want to suspend?");
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }

                            }

                        }

                        // Shutdown
                        Rectangle {
                            width: 100
                            height: 34
                            radius: Theme.cornerRadius
                            color: shutdownButton.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "power_settings_new"
                                    size: Theme.fontSizeSmall
                                    color: shutdownButton.containsMouse ? Theme.error : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Shutdown"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: shutdownButton.containsMouse ? Theme.error : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                id: shutdownButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerOptionsExpanded = false;
                                    root.powerActionRequested("poweroff", "Shutdown", "Are you sure you want to shutdown?");
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

                    // Single coordinated animation for power options
                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }

                    }

                }

                // Tab buttons
                DankTabBar {
                    width: parent.width
                    tabHeight: 40
                    currentIndex: {
                        let tabs = ["network", "audio"];
                        if (BluetoothService.available)
                            tabs.push("bluetooth");

                        tabs.push("display");
                        return tabs.indexOf(root.currentTab);
                    }
                    model: {
                        let tabs = [{
                            "text": "Network",
                            "icon": "wifi",
                            "id": "network"
                        }];
                        // Always show audio
                        tabs.push({
                            "text": "Audio",
                            "icon": "volume_up",
                            "id": "audio"
                        });
                        // Show Bluetooth only if available
                        if (BluetoothService.available)
                            tabs.push({
                            "text": "Bluetooth",
                            "icon": "bluetooth",
                            "id": "bluetooth"
                        });

                        // Always show display
                        tabs.push({
                            "text": "Display",
                            "icon": "brightness_6",
                            "id": "display"
                        });
                        return tabs;
                    }
                    onTabClicked: function(index) {
                        let tabs = ["network", "audio"];
                        if (BluetoothService.available)
                            tabs.push("bluetooth");

                        tabs.push("display");
                        root.currentTab = tabs[index];
                    }
                }

            }

            // Tab content area
            Rectangle {
                width: parent.width
                Layout.fillHeight: true
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.1)

                // Network Tab
                NetworkTab {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    visible: root.currentTab === "network"
                }

                // Audio Tab
                AudioTab {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    visible: root.currentTab === "audio"
                }

                // Bluetooth Tab
                BluetoothTab {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    visible: BluetoothService.available && root.currentTab === "bluetooth"
                }

                // Display Tab
                DisplayTab {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    visible: root.currentTab === "display"
                }

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }

                }

            }

        }

        // Power menu height animation
        Behavior on height {
            NumberAnimation {
                duration: Theme.shortDuration // Faster for height changes
                easing.type: Theme.standardEasing
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            controlCenterVisible = false;
        }
    }

}
