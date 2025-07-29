//NotificationCenter.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property bool notificationHistoryVisible: false

    visible: notificationHistoryVisible
    implicitWidth: 400
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

    // Background to close popup when clicking outside
    MouseArea {
        anchors.fill: parent
        onClicked: {
            notificationHistoryVisible = false;
        }
    }

    Rectangle {
        width: 400
        height: 500
        x: Screen.width - width - Theme.spacingL
        y: Theme.barHeight + Theme.spacingXS
        color: Theme.popupBackground()
        radius: Theme.cornerRadiusLarge
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 0.5
        opacity: notificationHistoryVisible ? 1 : 0
        // Animation
        transform: [
            Scale {
                id: scaleTransform

                origin.x: 400 // Use fixed width since popup is 400px wide
                origin.y: 0
                xScale: notificationHistoryVisible ? 1 : 0.95
                yScale: notificationHistoryVisible ? 1 : 0.8
            },
            Translate {
                id: translateTransform

                x: notificationHistoryVisible ? 0 : 15
                y: notificationHistoryVisible ? 0 : -30
            }
        ]
        states: [
            State {
                name: "visible"
                when: notificationHistoryVisible

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
                when: !notificationHistoryVisible

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

        // Prevent clicks from propagating to background
        MouseArea {
            // Stop propagation - do nothing

            anchors.fill: parent
            onClicked: {
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            // Header
            Item {
                width: parent.width
                height: 32

                Text {
                    text: "Notifications"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Clear All Button - fixed width aligned to right
                Rectangle {
                    width: 120
                    height: 28
                    radius: Theme.cornerRadius
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: NotificationService.notifications.length > 0
                    color: clearArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Theme.surfaceContainer
                    border.color: clearArea.containsMouse ? Theme.primary : Theme.outline
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: "delete_sweep"
                            size: Theme.iconSizeSmall
                            color: clearArea.containsMouse ? Theme.primary : Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Clear All"
                            font.pixelSize: Theme.fontSizeSmall
                            color: clearArea.containsMouse ? Theme.primary : Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: clearArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.clearAllNotifications()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }

                    }

                }

            }

            // Notification List
            ScrollView {
                width: parent.width
                height: parent.height - 120
                clip: true
                contentWidth: -1
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    // Quick reply height

                    model: NotificationService.groupedNotifications
                    spacing: Theme.spacingL
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 1500
                    maximumFlickVelocity: 2000

                    // Enhanced smooth animations to prevent layout jumping
                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }

                            NumberAnimation {
                                properties: "height"
                                from: 0
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }

                        }

                    }

                    remove: Transition {
                        SequentialAnimation {
                            // Pause to let internal content animations complete
                            PauseAnimation {
                                duration: 50
                            }

                            ParallelAnimation {
                                NumberAnimation {
                                    properties: "opacity"
                                    to: 0
                                    duration: Theme.mediumDuration
                                    easing.type: Theme.emphasizedEasing
                                }

                                NumberAnimation {
                                    properties: "height,anchors.topMargin,anchors.bottomMargin"
                                    to: 0
                                    duration: Theme.mediumDuration
                                    easing.type: Theme.emphasizedEasing
                                }

                            }

                        }

                    }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }

                    }

                    // Add move transition for internal content changes
                    move: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }

                    }

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool expanded: NotificationService.expandedGroups[modelData.key] || false
                        readonly property string groupKey: modelData.key

                        width: ListView.view.width
                        height: {
                            if (expanded && modelData.count >= 1) {
                                const baseHeight = (116 * modelData.count) + (12 * (modelData.count - 1));
                                // Add extra bottom margin for expanded groups
                                const bottomMargin = modelData.count === 1 ? 50 : (modelData.count < 3 ? 40 : 20);
                                return baseHeight + bottomMargin;
                            }
                            return 116;
                        }
                        radius: 12
                        color: Theme.popupBackground()
                        border.color: modelData.latestNotification.urgency === 2 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: modelData.latestNotification.urgency === 2 ? 2 : 1
                        clip: true

                        // Priority indicator for urgent notifications
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

                        // Collapsed view - show latest notification using popup style
                        Item {
                            id: collapsedContent

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 12
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            height: 92
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
                                            // No truncation for notification center - show full text

                                            property bool hasUrls: {
                                                const urlRegex = /(https?:\/\/[^\s]+)/g;
                                                return urlRegex.test(modelData.latestNotification.body);
                                            }

                                            text: {
                                                // Auto-detect and make URLs clickable, with truncation for center notifications
                                                let bodyText = modelData.latestNotification.body;
                                                const urlRegex = /(https?:\/\/[^\s]+)/g;
                                                return bodyText.replace(urlRegex, '<a href="$1" style="color: ' + Theme.primary + '; text-decoration: underline;">$1</a>');
                                            }
                                            color: Theme.surfaceVariantText
                                            font.pixelSize: Theme.fontSizeSmall
                                            width: parent.width
                                            elide: Text.ElideRight
                                            maximumLineCount: modelData.count > 1 ? 2 : 3
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
                                        }
                                        onExited: {
                                            closeButton.isHovered = false;
                                        }
                                        onClicked: NotificationService.dismissGroup(modelData.key)
                                    }

                                }

                            }

                        }

                        // Expanded view - shows all notifications stacked
                        Column {
                            id: expandedContent

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 14 // Reduced from Theme.spacingL (16px) by 10%
                            anchors.bottomMargin: 14 // Reduced from Theme.spacingL (16px) by 10%
                            anchors.leftMargin: Theme.spacingL
                            anchors.rightMargin: Theme.spacingL
                            spacing: 9 // Reduced from Theme.spacingM (12px) by 1/4
                            visible: expanded

                            // 1st tier controls with app name - optimized spacing
                            Item {
                                width: parent.width
                                height: 40

                                // App name and count badge - left side
                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingS

                                    Text {
                                        text: modelData.appName
                                        color: Theme.surfaceText
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Message count badge when expanded
                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: Theme.primary
                                        visible: modelData.count > 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.count.toString()
                                            color: Theme.primaryText
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                        }

                                    }

                                }

                                // Controls container - fixed position on right
                                Item {
                                    width: 48
                                    height: 24
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        anchors.left: parent.left
                                        color: collapseAreaTop.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "expand_less"
                                            size: 14
                                            color: Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: collapseAreaTop

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
                                        anchors.right: parent.right
                                        color: dismissAllAreaTop.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "close"
                                            size: 14
                                            color: Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: dismissAllAreaTop

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: NotificationService.dismissGroup(modelData.key)
                                        }

                                    }

                                }

                            }

                            // Individual notifications
                            Column {
                                width: parent.width
                                spacing: 5 // Reduced from Theme.spacingS (8px) by 1/3

                                Repeater {
                                    model: modelData.notifications.slice(0, 10)

                                    delegate: Rectangle {
                                        required property var modelData

                                        width: parent.width
                                        height: Math.max(48, 32 + contentColumn.height + Theme.spacingM * 2) // 32 for icon height, plus content
                                        radius: Theme.cornerRadius
                                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                                        border.color: modelData.urgency === 2 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : "transparent"
                                        border.width: modelData.urgency === 2 ? 1 : 0
                                        clip: true

                                        Item {
                                            id: notifContent

                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: Theme.spacingM
                                            height: Math.max(32, contentColumn.height)

                                            Rectangle {
                                                readonly property bool hasNotificationImage: modelData.image && modelData.image !== ""

                                                width: 32
                                                height: 32
                                                radius: 16
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                                border.width: 1

                                                IconImage {
                                                    anchors.fill: parent
                                                    anchors.margins: 1
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
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                    color: Theme.primaryText
                                                }

                                            }

                                            // Individual controls - expand and dismiss buttons
                                            Row {
                                                width: 50
                                                height: 24
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                anchors.topMargin: -4 // Move up into title area
                                                spacing: 2

                                                // Expand/collapse button for 2nd tier
                                                Rectangle {
                                                    property bool isExpanded: NotificationService.expandedMessages[modelData.notification.id] || false

                                                    width: 20
                                                    height: 20
                                                    radius: 10
                                                    color: individualExpandArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"
                                                    visible: (modelData.body || "").length > 80 // Only show if body text is long enough

                                                    DankIcon {
                                                        anchors.centerIn: parent
                                                        name: parent.isExpanded ? "expand_less" : "expand_more"
                                                        size: 12
                                                        color: Theme.surfaceText
                                                    }

                                                    MouseArea {
                                                        id: individualExpandArea

                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: NotificationService.toggleMessageExpansion(modelData.notification.id)
                                                    }

                                                }

                                                // Individual dismiss button
                                                Rectangle {
                                                    width: 20
                                                    height: 20
                                                    radius: 10
                                                    color: individualDismissArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : "transparent"

                                                    DankIcon {
                                                        anchors.centerIn: parent
                                                        name: "close"
                                                        size: 12
                                                        color: individualDismissArea.containsMouse ? Theme.primary : Theme.surfaceText
                                                    }

                                                    MouseArea {
                                                        id: individualDismissArea

                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: NotificationService.dismissNotification(modelData)
                                                    }

                                                }

                                            }

                                            Item {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 44
                                                anchors.right: parent.right
                                                anchors.rightMargin: 24 // Align text with close button
                                                anchors.top: parent.top
                                                height: contentColumn.height

                                                Column {
                                                    // COMMENTED OUT: Individual inline reply
                                                    /*
                                                Row {
                                                    width: parent.width
                                                    spacing: Theme.spacingS
                                                    visible: modelData.notification.hasInlineReply

                                                    Rectangle {
                                                        width: parent.width - 50
                                                        height: 28
                                                        radius: 14
                                                        color: Theme.surface
                                                        border.color: replyField.activeFocus ? Theme.primary : Theme.outline
                                                        border.width: 1

                                                        TextField {
                                                            id: replyField

                                                            anchors.fill: parent
                                                            anchors.margins: Theme.spacingXS
                                                            placeholderText: modelData.notification.inlineReplyPlaceholder || "Reply..."
                                                            color: Theme.surfaceText
                                                            font.pixelSize: 11
                                                            onAccepted: {
                                                                if (text.length > 0) {
                                                                    modelData.notification.sendInlineReply(text);
                                                                    text = "";
                                                                }
                                                            }

                                                            background: Item {
                                                            }

                                                        }

                                                    }

                                                    Rectangle {
                                                        width: 42
                                                        height: 28
                                                        radius: 14
                                                        color: replyField.text.length > 0 ? Theme.primary : Theme.surfaceContainer

                                                        DankIcon {
                                                            anchors.centerIn: parent
                                                            name: "send"
                                                            size: 12
                                                            color: replyField.text.length > 0 ? Theme.primaryText : Theme.surfaceVariantText
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            enabled: replyField.text.length > 0
                                                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                            onClicked: {
                                                                modelData.notification.sendInlineReply(replyField.text);
                                                                replyField.text = "";
                                                            }
                                                        }

                                                    }

                                                }
                                                */

                                                    id: contentColumn

                                                    property bool isMessageExpanded: NotificationService.expandedMessages[modelData.notification.id] || false

                                                    width: parent.width
                                                    spacing: 2 // Reduced from Theme.spacingXS (4px) by 2px

                                                    // Title • timestamp format
                                                    Text {
                                                        text: {
                                                            const summary = modelData.summary || "";
                                                            const timeStr = modelData.timeStr || "";
                                                            if (summary && timeStr)
                                                                return summary + " • " + timeStr;
                                                            else if (summary)
                                                                return summary;
                                                            else
                                                                return "Message • " + timeStr;
                                                        }
                                                        color: Theme.surfaceText
                                                        font.pixelSize: Theme.fontSizeSmall
                                                        font.weight: Font.Medium
                                                        width: parent.width
                                                        elide: Text.ElideRight
                                                        maximumLineCount: 1
                                                    }

                                                    // Body text with expandable behavior
                                                    Text {
                                                        text: modelData.body
                                                        color: Theme.surfaceVariantText
                                                        font.pixelSize: Theme.fontSizeSmall
                                                        width: parent.width
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: parent.isMessageExpanded ? -1 : 3 // Unlimited when expanded, 3 when collapsed (more space in center)
                                                        elide: parent.isMessageExpanded ? Text.ElideNone : Text.ElideRight
                                                        visible: text.length > 0
                                                    }

                                                    // Clickable area for View action on individual message
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            // Find and invoke the View action
                                                            if (modelData.actions) {
                                                                for (const action of modelData.actions) {
                                                                    if (action.text && action.text.toLowerCase() === "view") {
                                                                        if (action.invoke)
                                                                            action.invoke();

                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // Tap to expand for collapsed groups
                        MouseArea {
                            anchors.fill: parent
                            visible: !expanded && modelData.count > 1
                            onClicked: NotificationService.toggleGroupExpansion(modelData.key)
                            z: -1
                        }

                        Behavior on height {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 25
                                }

                                NumberAnimation {
                                    duration: Theme.mediumDuration
                                    easing.type: Theme.emphasizedEasing
                                }

                            }

                        }

                    }

                }

                // Empty state
                Item {
                    width: parent.width
                    height: 200
                    visible: NotificationService.notifications.length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingM
                        width: parent.width * 0.8

                        DankIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "notifications_none"
                            size: Theme.iconSizeLarge + 16
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.3)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No notifications"
                            font.pixelSize: Theme.fontSizeLarge
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Notifications will appear here"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.4)
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                    }

                }

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
        onClicked: notificationHistoryVisible = false
    }

}
