import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    visible: NotificationService.groupedPopups.length > 0
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"
    implicitWidth: 400
    implicitHeight: Math.min(500, notificationsList.height + 32)

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.barHeight
        right: 12
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        width: 380
        height: Math.min(500 - 32, notificationsList.height + 32) // Match notification center height minus margins
        color: "transparent"
        radius: 12
        clip: true

        ScrollView {
            anchors.fill: parent
            clip: true

            Column {
                id: notificationsList

                width: parent.width
                spacing: 12

                Repeater {
                    model: NotificationService.groupedPopups

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool expanded: NotificationService.expandedGroups[modelData.key] || false
                        readonly property string groupKey: modelData.key
                        readonly property bool isPopup: modelData.latestNotification.popup
                        readonly property int expireTimeout: modelData.latestNotification.notification.expireTimeout
                        property string stableGroupKey: ""
                        // Watch for changes to latest notification (new message joins group)
                        property var currentLatestNotification: modelData.latestNotification

                        Component.onCompleted: {
                            stableGroupKey = modelData.key;
                        }
                        width: parent.width
                        height: {
                            if (expanded && modelData.count >= 1) {
                                const baseHeight = (116 * modelData.count) + (12 * (modelData.count - 1));
                                // Add extra bottom margin for View/Dismiss buttons when there are fewer than 3 messages
                                const bottomMargin = modelData.count === 1 ? 70 : (modelData.count < 3 ? 50 : 0);
                                return baseHeight + bottomMargin;
                            }
                            return 116;
                        }
                        radius: 12
                        color: Theme.popupBackground()
                        border.color: modelData.latestNotification.urgency === 2 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: modelData.latestNotification.urgency === 2 ? 2 : 1
                        clip: true
                        onCurrentLatestNotificationChanged: {
                            if (isPopup && !cardHoverArea.containsMouse)
                                dismissTimer.restart();

                        }

                        Rectangle {
                            width: 4
                            height: parent.height - 16
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 2
                            color: Theme.primary
                            visible: modelData.latestNotification.urgency === 2
                        }

                        // Collapsed view - show only latest notification
                        Item {
                            id: collapsedContent

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 12
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            height: 86
                            visible: !expanded

                            Rectangle {
                                id: iconContainer

                                readonly property bool hasNotificationImage: modelData.latestNotification.image && modelData.latestNotification.image !== ""
                                readonly property bool appIconIsImage: modelData.latestNotification.appIcon && (modelData.latestNotification.appIcon.startsWith("file://") || modelData.latestNotification.appIcon.startsWith("http://") || modelData.latestNotification.appIcon.startsWith("https://"))

                                width: 55
                                height: 55
                                radius: 27.5
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                border.color: "transparent"
                                border.width: 0
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                                IconImage {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: {
                                        // Priority 1: Use notification image if available
                                        if (parent.hasNotificationImage)
                                            return modelData.latestNotification.cleanImage;

                                        // Priority 2: Use appIcon - handle URLs directly, use iconPath for icon names
                                        if (modelData.latestNotification.appIcon) {
                                            const appIcon = modelData.latestNotification.appIcon;
                                            if (appIcon.startsWith("file://") || appIcon.startsWith("http://") || appIcon.startsWith("https://"))
                                                return appIcon;

                                            return Quickshell.iconPath(appIcon, "");
                                        }
                                        return "";
                                    }
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !parent.hasNotificationImage && (!modelData.latestNotification.appIcon || modelData.latestNotification.appIcon === "")
                                    text: {
                                        const appName = modelData.appName || "?";
                                        return appName.charAt(0).toUpperCase();
                                    }
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                    color: Theme.primaryText
                                }

                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: Theme.primary
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: -2
                                    anchors.rightMargin: -2
                                    visible: modelData.count > 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.count > 99 ? "99+" : modelData.count.toString()
                                        color: Theme.primaryText
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                    }

                                }

                            }

                            Rectangle {
                                id: textContainer

                                anchors.left: iconContainer.right
                                anchors.leftMargin: 12
                                anchors.right: controlsContainer.left
                                anchors.rightMargin: 0
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                color: "transparent"
                                opacity: 1
                                border.color: "transparent"
                                border.width: 0

                                Item {
                                    width: parent.width
                                    height: parent.height
                                    anchors.top: parent.top
                                    anchors.topMargin: 2

                                    Column {
                                        id: textContent

                                        width: parent.width
                                        spacing: 2

                                        Text {
                                            width: parent.width
                                            text: {
                                                if (modelData.latestNotification.timeStr.length > 0)
                                                    return modelData.appName + " • " + modelData.latestNotification.timeStr;
                                                else
                                                    return modelData.appName;
                                            }
                                            color: Theme.surfaceVariantText
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            text: modelData.latestNotification.summary
                                            color: Theme.surfaceText
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            width: parent.width
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            visible: text.length > 0
                                        }

                                        Text {
                                            property bool hasUrls: {
                                                const urlRegex = /(https?:\/\/[^\s]+)/g;
                                                return urlRegex.test(modelData.latestNotification.body);
                                            }

                                            text: {
                                                // Auto-detect and make URLs clickable, with truncation for popups
                                                let bodyText = modelData.latestNotification.body;
                                                // Truncate to 108 characters max for popup notifications
                                                if (bodyText.length > 105)
                                                    bodyText = bodyText.substring(0, 102) + "...";

                                                const urlRegex = /(https?:\/\/[^\s]+)/g;
                                                return bodyText.replace(urlRegex, '<a href="$1" style="color: ' + Theme.primary + '; text-decoration: underline;">$1</a>');
                                            }
                                            color: Theme.surfaceVariantText
                                            font.pixelSize: Theme.fontSizeSmall
                                            width: parent.width
                                            elide: Text.ElideRight
                                            maximumLineCount: modelData.count > 1 ? 1 : 2
                                            wrapMode: Text.WordWrap
                                            visible: text.length > 0
                                            textFormat: Text.RichText
                                            onLinkActivated: function(link) {
                                                Qt.openUrlExternally(link);
                                            }
                                        }

                                    }

                                }

                            }

                            Item {
                                id: controlsContainer

                                anchors.right: parent.right
                                anchors.rightMargin: 0
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                width: modelData.count > 1 ? 40 : 20 // Dynamic width: 40px for expand+close, 20px for close only
                                height: 24

                                // Expand button - always takes up space but only visible when needed
                                Rectangle {
                                    id: collapsedExpandButton

                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: expandArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                                    visible: modelData.count > 1

                                    DankIcon {
                                        anchors.centerIn: parent
                                        name: expanded ? "expand_less" : "expand_more"
                                        size: 14
                                        color: Theme.surfaceText
                                    }

                                    MouseArea {
                                        id: expandArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NotificationService.toggleGroupExpansion(modelData.key)
                                    }

                                }

                                // Close button - always positioned at the right edge
                                Rectangle {
                                    id: closeButton

                                    property bool isHovered: false

                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: isHovered ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                                    z: 10

                                    DankIcon {
                                        id: closeIcon

                                        name: "close"
                                        size: 14
                                        color: closeButton.isHovered ? Theme.primary : Theme.surfaceText
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        id: dismissArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        z: 11
                                        onEntered: {
                                            closeButton.isHovered = true;
                                            dismissTimer.stop();
                                        }
                                        onExited: {
                                            closeButton.isHovered = false;
                                            if (modelData.latestNotification.popup && !cardHoverArea.containsMouse)
                                                dismissTimer.restart();

                                        }
                                        onClicked: NotificationService.dismissGroup(modelData.key)
                                    }

                                }

                            }

                        }

                        // Expanded view - show all notifications in group
                        Item {
                            anchors.fill: parent
                            anchors.margins: 16
                            visible: expanded

                            Column {
                                id: expandedColumn

                                width: parent.width
                                spacing: 8

                                // Header with app name and count
                                Item {
                                    width: parent.width
                                    height: 32

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        Text {
                                            text: modelData.appName
                                            color: Theme.surfaceText
                                            font.pixelSize: Theme.fontSizeLarge
                                            font.weight: Font.Bold
                                        }

                                        Rectangle {
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: Theme.primary
                                            visible: modelData.count > 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.count.toString()
                                                color: Theme.primaryText
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }

                                        }

                                    }

                                    Item {
                                        id: expandedControls

                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 56
                                        height: 24

                                        Row {
                                            anchors.fill: parent
                                            spacing: 8

                                            Rectangle {
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: expandedExpandArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                                DankIcon {
                                                    anchors.centerIn: parent
                                                    name: "expand_less"
                                                    size: 14
                                                    color: Theme.surfaceText
                                                }

                                                MouseArea {
                                                    id: expandedExpandArea

                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: NotificationService.toggleGroupExpansion(modelData.key)
                                                }

                                            }

                                            Rectangle {
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: expandedCloseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                                DankIcon {
                                                    anchors.centerIn: parent
                                                    name: "close"
                                                    size: 14
                                                    color: expandedCloseArea.containsMouse ? Theme.primary : Theme.surfaceText
                                                }

                                                MouseArea {
                                                    id: expandedCloseArea

                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: NotificationService.dismissGroup(modelData.key)
                                                }

                                            }

                                        }

                                    }

                                }

                                // Scrollable list of individual notifications
                                Rectangle {
                                    width: parent.width
                                    height: Math.min(400, modelData.notifications.length * 90) // Fixed height constraint for inner scroll
                                    radius: 8
                                    color: "transparent"
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                    border.width: 1
                                    clip: true

                                    ScrollView {
                                        anchors.fill: parent
                                        clip: true

                                        Column {
                                            width: parent.width
                                            spacing: 8

                                            Repeater {
                                                model: modelData.notifications

                                                delegate: Rectangle {
                                                    required property var modelData
                                                    readonly property bool messageExpanded: NotificationService.expandedMessages[modelData.notification.id] || false

                                                    width: parent.width
                                                    height: messageExpanded ? Math.min(120, 50 + (bodyText.contentHeight || 0)) : 80
                                                    radius: 8
                                                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
                                                    border.color: "transparent"
                                                    border.width: 0

                                                    Item {
                                                        anchors.fill: parent
                                                        anchors.margins: 12

                                                        // Small icon for individual message
                                                        Rectangle {
                                                            id: messageIcon

                                                            readonly property bool hasNotificationImage: modelData.image && modelData.image !== ""
                                                            readonly property bool appIconIsImage: modelData.appIcon && (modelData.appIcon.startsWith("file://") || modelData.appIcon.startsWith("http://") || modelData.appIcon.startsWith("https://"))

                                                            width: 32
                                                            height: 32
                                                            radius: 16
                                                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                                            anchors.left: parent.left
                                                            anchors.top: parent.top

                                                            IconImage {
                                                                anchors.fill: parent
                                                                anchors.margins: 2
                                                                source: {
                                                                    // Priority 1: Use notification image if available
                                                                    if (parent.hasNotificationImage)
                                                                        return modelData.cleanImage;

                                                                    // Priority 2: Use appIcon - handle URLs directly, use iconPath for icon names
                                                                    if (modelData.appIcon) {
                                                                        const appIcon = modelData.appIcon;
                                                                        if (appIcon.startsWith("file://") || appIcon.startsWith("http://") || appIcon.startsWith("https://"))
                                                                            return appIcon;

                                                                        return Quickshell.iconPath(appIcon, "");
                                                                    }
                                                                    return "";
                                                                }
                                                                visible: status === Image.Ready
                                                            }

                                                            Text {
                                                                anchors.centerIn: parent
                                                                visible: !parent.hasNotificationImage && (!modelData.appIcon || modelData.appIcon === "")
                                                                text: {
                                                                    const appName = modelData.appName || "?";
                                                                    return appName.charAt(0).toUpperCase();
                                                                }
                                                                font.pixelSize: 14
                                                                font.weight: Font.Bold
                                                                color: Theme.primaryText
                                                            }

                                                        }

                                                        // Message content
                                                        Column {
                                                            anchors.left: messageIcon.right
                                                            anchors.leftMargin: 12
                                                            anchors.right: messageControls.left
                                                            anchors.rightMargin: 0
                                                            anchors.top: parent.top
                                                            spacing: 4

                                                            // App Title • Timestamp line
                                                            Text {
                                                                width: parent.width
                                                                text: {
                                                                    const appName = modelData.appName || "";
                                                                    const timeStr = modelData.timeStr || "";
                                                                    if (timeStr.length > 0)
                                                                        return appName + " • " + timeStr;
                                                                    else
                                                                        return appName;
                                                                }
                                                                color: Theme.surfaceVariantText
                                                                font.pixelSize: Theme.fontSizeSmall
                                                                font.weight: Font.Medium
                                                                elide: Text.ElideRight
                                                                maximumLineCount: 1
                                                            }

                                                            // Summary line (if exists)
                                                            Text {
                                                                width: parent.width
                                                                text: modelData.summary || ""
                                                                color: Theme.surfaceText
                                                                font.pixelSize: Theme.fontSizeMedium
                                                                font.weight: Font.Medium
                                                                elide: Text.ElideRight
                                                                maximumLineCount: 1
                                                                visible: text.length > 0
                                                            }

                                                            // Body text with expand capability
                                                            Text {
                                                                id: bodyText

                                                                width: parent.width
                                                                text: {
                                                                    // Show up to 500 characters when expanded
                                                                    // Show truncated version when collapsed

                                                                    const body = modelData.body || "";
                                                                    if (messageExpanded)
                                                                        return body.length > 500 ? body.substring(0, 497) + "..." : body;
                                                                    else
                                                                        return body.length > 80 ? body.substring(0, 77) + "..." : body;
                                                                }
                                                                color: Theme.surfaceVariantText
                                                                font.pixelSize: Theme.fontSizeSmall
                                                                elide: messageExpanded ? Text.ElideNone : Text.ElideRight
                                                                maximumLineCount: messageExpanded ? -1 : 2
                                                                wrapMode: Text.WordWrap
                                                                visible: text.length > 0
                                                            }

                                                        }

                                                        // Message controls (expand and close buttons)
                                                        Row {
                                                            id: messageControls

                                                            anchors.right: parent.right
                                                            anchors.top: parent.top
                                                            spacing: 4

                                                            // Expand/collapse button for individual message
                                                            Rectangle {
                                                                id: expandButton

                                                                width: 20
                                                                height: 20
                                                                radius: 10
                                                                color: expandMessageArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                                                                visible: (modelData.body || "").length > 80

                                                                DankIcon {
                                                                    anchors.centerIn: parent
                                                                    name: messageExpanded ? "expand_less" : "expand_more"
                                                                    size: 12
                                                                    color: Theme.surfaceText
                                                                }

                                                                MouseArea {
                                                                    id: expandMessageArea

                                                                    anchors.fill: parent
                                                                    hoverEnabled: true
                                                                    cursorShape: Qt.PointingHandCursor
                                                                    onClicked: NotificationService.toggleMessageExpansion(modelData.notification.id)
                                                                }

                                                            }

                                                            // Close button for individual message
                                                            Rectangle {
                                                                width: 20
                                                                height: 20
                                                                radius: 10
                                                                color: closeMessageArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                                                DankIcon {
                                                                    anchors.centerIn: parent
                                                                    name: "close"
                                                                    size: 12
                                                                    color: closeMessageArea.containsMouse ? Theme.primary : Theme.surfaceText
                                                                }

                                                                MouseArea {
                                                                    id: closeMessageArea

                                                                    anchors.fill: parent
                                                                    hoverEnabled: true
                                                                    cursorShape: Qt.PointingHandCursor
                                                                    onClicked: NotificationService.dismissNotification(modelData)
                                                                }

                                                            }

                                                        }

                                                    }

                                                    Behavior on height {
                                                        NumberAnimation {
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

                        // Main hover area for persistence
                        MouseArea {
                            id: cardHoverArea

                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            propagateComposedEvents: true
                            z: 0
                            onEntered: {
                                dismissTimer.stop();
                            }
                            onExited: {
                                if (modelData.latestNotification.popup)
                                    dismissTimer.restart();

                            }
                        }

                        // View button positioned at bottom-right of notification card
                        Rectangle {
                            id: viewButton

                            property bool isHovered: false

                            anchors.right: dismissButton.left
                            anchors.rightMargin: 4
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            width: viewText.width + 16
                            height: viewText.height + 8
                            radius: 6
                            color: isHovered ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : "transparent"
                            z: 10

                            Text {
                                id: viewText

                                text: "View"
                                color: viewButton.isHovered ? Theme.primary : Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: viewArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: 11
                                onEntered: {
                                    viewButton.isHovered = true;
                                    dismissTimer.stop();
                                }
                                onExited: {
                                    viewButton.isHovered = false;
                                    if (modelData.latestNotification.popup && !cardHoverArea.containsMouse)
                                        dismissTimer.restart();

                                }
                                onClicked: {
                                    // Handle navigation to source message
                                    if (modelData.latestNotification.actions) {
                                        for (const action of modelData.latestNotification.actions) {
                                            if (action.text && action.text.toLowerCase() === "view") {
                                                if (action.invoke) {
                                                    action.invoke();
                                                    return ;
                                                }
                                            }
                                        }
                                        // If no View action, try the first available action
                                        if (modelData.latestNotification.actions.length > 0) {
                                            const firstAction = modelData.latestNotification.actions[0];
                                            if (firstAction.invoke)
                                                firstAction.invoke();

                                        }
                                    }
                                }
                            }

                        }

                        // Dismiss button positioned at bottom-right of notification card
                        Rectangle {
                            id: dismissButton

                            property bool isHovered: false

                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            width: dismissText.width + 16
                            height: dismissText.height + 8
                            radius: 6
                            color: isHovered ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : "transparent"
                            z: 10

                            Text {
                                id: dismissText

                                text: "Dismiss"
                                color: dismissButton.isHovered ? Theme.primary : Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: popupDismissArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: 11
                                onEntered: {
                                    dismissButton.isHovered = true;
                                    dismissTimer.stop();
                                }
                                onExited: {
                                    dismissButton.isHovered = false;
                                    if (modelData.latestNotification.popup && !cardHoverArea.containsMouse)
                                        dismissTimer.restart();

                                }
                                onClicked: {
                                    // Move to notification center (don't close)
                                    const groupKey = stableGroupKey || modelData.key;
                                    console.log("Manually hiding notification group from popup:", groupKey);
                                    modelData.latestNotification.popup = false;
                                    // Clear expansion state when manually hiding from popup
                                    NotificationService.clearGroupExpansionState(groupKey);
                                }
                            }

                        }

                        Timer {
                            id: dismissTimer

                            running: isPopup
                            interval: 5000 // Fixed 5-second timer for all notifications
                            onTriggered: {
                                // Move to notification center (don't dismiss completely)
                                const groupKey = stableGroupKey || modelData.key;
                                console.log("Auto-hiding notification group from popup:", groupKey);
                                modelData.latestNotification.popup = false;
                                // Clear expansion state when hiding from popup
                                NotificationService.clearGroupExpansionState(groupKey);
                            }
                        }

                        transform: Translate {
                            x: root.visible ? 0 : 400

                            Behavior on x {
                                NumberAnimation {
                                    duration: 350
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.mediumDuration
            easing.type: Theme.emphasizedEasing
        }

    }

}
