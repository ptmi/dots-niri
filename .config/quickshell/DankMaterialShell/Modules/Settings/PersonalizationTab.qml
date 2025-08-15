import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Modals
import qs.Services
import qs.Widgets

Item {
    id: personalizationTab

    property alias profileBrowser: profileBrowserLoader.item
    property alias wallpaperBrowser: wallpaperBrowserLoader.item

    Component.onCompleted: {
        // Access WallpaperCyclingService to ensure it's initialized
        WallpaperCyclingService.cyclingActive;
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        anchors.bottomMargin: Theme.spacingXL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            // Profile Image Section
            StyledRect {
                width: parent.width
                height: profileSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: profileSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "person"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Profile Image"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingL

                        Item {
                            id: avatarContainer

                            property bool hasImage: avatarImageSource.status === Image.Ready

                            width: 80
                            height: 80

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.color: Theme.primary
                                border.width: 1
                                visible: parent.hasImage
                            }

                            Image {
                                id: avatarImageSource

                                source: {
                                    if (PortalService.profileImage === "")
                                        return "";

                                    if (PortalService.profileImage.startsWith("/"))
                                        return "file://" + PortalService.profileImage;

                                    return PortalService.profileImage;
                                }
                                smooth: true
                                asynchronous: true
                                mipmap: true
                                cache: true
                                visible: false
                            }

                            MultiEffect {
                                anchors.fill: parent
                                anchors.margins: 5
                                source: avatarImageSource
                                maskEnabled: true
                                maskSource: settingsCircularMask
                                visible: avatarContainer.hasImage
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1
                            }

                            Item {
                                id: settingsCircularMask

                                width: 70
                                height: 70
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

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Theme.primary
                                visible: !parent.hasImage

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "person"
                                    size: Theme.iconSizeLarge + 8
                                    color: Theme.primaryText
                                }

                            }

                            DankIcon {
                                anchors.centerIn: parent
                                name: "warning"
                                size: Theme.iconSizeLarge
                                color: Theme.error
                                visible: PortalService.profileImage !== "" && avatarImageSource.status === Image.Error
                            }

                        }

                        Column {
                            width: parent.width - 80 - Theme.spacingL
                            spacing: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: PortalService.profileImage ? PortalService.profileImage.split('/').pop() : "No profile image selected"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                elide: Text.ElideMiddle
                                width: parent.width
                            }

                            StyledText {
                                text: PortalService.profileImage ? PortalService.profileImage : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideMiddle
                                width: parent.width
                                visible: PortalService.profileImage !== ""
                            }

                            Row {
                                spacing: Theme.spacingXS
                                visible: !PortalService.accountsServiceAvailable

                                DankIcon {
                                    name: "error"
                                    size: Theme.iconSizeSmall
                                    color: Theme.error
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "accountsservice missing or not accessible"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.error
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            Row {
                                spacing: Theme.spacingS

                                StyledRect {
                                    width: 100
                                    height: 32
                                    radius: Theme.cornerRadius
                                    color: Theme.primary

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingXS

                                        DankIcon {
                                            name: "folder_open"
                                            size: Theme.iconSizeSmall
                                            color: Theme.primaryText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: "Browse"
                                            color: Theme.primaryText
                                            font.pixelSize: Theme.fontSizeSmall
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            profileBrowserLoader.active = true;
                                            profileBrowser.visible = true;
                                        }
                                    }

                                }

                                StyledRect {
                                    width: 80
                                    height: 32
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceVariant
                                    opacity: PortalService.profileImage !== "" ? 1 : 0.5

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingXS

                                        DankIcon {
                                            name: "clear"
                                            size: Theme.iconSizeSmall
                                            color: Theme.surfaceVariantText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: "Clear"
                                            color: Theme.surfaceVariantText
                                            font.pixelSize: Theme.fontSizeSmall
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: PortalService.profileImage !== ""
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            PortalService.setProfileImage("");
                                        }
                                    }

                                }

                            }

                        }

                    }

                }

            }

            // Wallpaper Section
            StyledRect {
                width: parent.width
                height: wallpaperSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: wallpaperSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "wallpaper"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Wallpaper"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingL

                        StyledRect {
                            width: 160
                            height: 90
                            radius: Theme.cornerRadius
                            color: Theme.surfaceVariant
                            border.color: Theme.outline
                            border.width: 1

                            CachingImage {
                                anchors.fill: parent
                                anchors.margins: 1
                                imagePath: SessionData.wallpaperPath || ""
                                fillMode: Image.PreserveAspectCrop
                                visible: SessionData.wallpaperPath !== ""
                                maxCacheSize: 160
                                layer.enabled: true

                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: wallpaperMask
                                    maskThresholdMin: 0.5
                                    maskSpreadAtMin: 1
                                }

                            }

                            Rectangle {
                                id: wallpaperMask

                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: "black"
                                visible: false
                                layer.enabled: true
                            }

                            DankIcon {
                                anchors.centerIn: parent
                                name: "image"
                                size: Theme.iconSizeLarge + 8
                                color: Theme.surfaceVariantText
                                visible: SessionData.wallpaperPath === ""
                            }

                        }

                        Column {
                            width: parent.width - 160 - Theme.spacingL
                            spacing: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: SessionData.wallpaperPath ? SessionData.wallpaperPath.split('/').pop() : "No wallpaper selected"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                            }

                            StyledText {
                                text: SessionData.wallpaperPath ? SessionData.wallpaperPath : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                                visible: SessionData.wallpaperPath !== ""
                            }

                            Row {
                                spacing: Theme.spacingS

                                StyledRect {
                                    width: 100
                                    height: 32
                                    radius: Theme.cornerRadius
                                    color: Theme.primary

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingXS

                                        DankIcon {
                                            name: "folder_open"
                                            size: Theme.iconSizeSmall
                                            color: Theme.primaryText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: "Browse"
                                            color: Theme.primaryText
                                            font.pixelSize: Theme.fontSizeSmall
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            wallpaperBrowserLoader.active = true;
                                            wallpaperBrowser.visible = true;
                                        }
                                    }

                                }

                                StyledRect {
                                    width: 80
                                    height: 32
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceVariant
                                    opacity: SessionData.wallpaperPath !== "" ? 1 : 0.5

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingXS

                                        DankIcon {
                                            name: "clear"
                                            size: Theme.iconSizeSmall
                                            color: Theme.surfaceVariantText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: "Clear"
                                            color: Theme.surfaceVariantText
                                            font.pixelSize: Theme.fontSizeSmall
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: SessionData.wallpaperPath !== ""
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            SessionData.setWallpaper("");
                                        }
                                    }

                                }

                            }

                            // Wallpaper Cycling Section
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.outline
                                opacity: 0.2
                                visible: SessionData.wallpaperPath !== ""
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingM
                                visible: SessionData.wallpaperPath !== ""

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingM

                                    DankIcon {
                                        name: "schedule"
                                        size: Theme.iconSize
                                        color: SessionData.wallpaperCyclingEnabled ? Theme.primary : Theme.surfaceVariantText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - Theme.iconSize - Theme.spacingM - controlsRow.width - Theme.spacingM
                                        spacing: Theme.spacingXS
                                        anchors.verticalCenter: parent.verticalCenter

                                        StyledText {
                                            text: "Wallpaper Cycling"
                                            font.pixelSize: Theme.fontSizeLarge
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        StyledText {
                                            text: "Automatically cycle through wallpapers in the same folder"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            width: parent.width
                                        }

                                    }

                                    Row {
                                        id: controlsRow

                                        spacing: Theme.spacingS
                                        anchors.verticalCenter: parent.verticalCenter

                                        StyledRect {
                                            width: 60
                                            height: 32
                                            radius: Theme.cornerRadius
                                            color: prevButtonArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8) : Theme.primary
                                            opacity: SessionData.wallpaperPath ? 1 : 0.5

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: Theme.spacingXS

                                                DankIcon {
                                                    name: "skip_previous"
                                                    size: Theme.iconSizeSmall
                                                    color: Theme.primaryText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                StyledText {
                                                    text: "Prev"
                                                    color: Theme.primaryText
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                            }

                                            MouseArea {
                                                id: prevButtonArea

                                                anchors.fill: parent
                                                enabled: SessionData.wallpaperPath
                                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                hoverEnabled: true
                                                onClicked: {
                                                    WallpaperCyclingService.cyclePrevManually();
                                                }
                                            }

                                        }

                                        StyledRect {
                                            width: 60
                                            height: 32
                                            radius: Theme.cornerRadius
                                            color: nextButtonArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8) : Theme.primary
                                            opacity: SessionData.wallpaperPath ? 1 : 0.5

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: Theme.spacingXS

                                                DankIcon {
                                                    name: "skip_next"
                                                    size: Theme.iconSizeSmall
                                                    color: Theme.primaryText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                StyledText {
                                                    text: "Next"
                                                    color: Theme.primaryText
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                            }

                                            MouseArea {
                                                id: nextButtonArea

                                                anchors.fill: parent
                                                enabled: SessionData.wallpaperPath
                                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                hoverEnabled: true
                                                onClicked: {
                                                    WallpaperCyclingService.cycleNextManually();
                                                }
                                            }

                                        }

                                        DankToggle {
                                            id: cyclingToggle

                                            anchors.verticalCenter: parent.verticalCenter
                                            checked: SessionData.wallpaperCyclingEnabled
                                            onToggled: (toggled) => {
                                                return SessionData.setWallpaperCyclingEnabled(toggled);
                                            }
                                        }

                                    }

                                }

                                // Cycling mode and settings
                                Column {
                                    width: parent.width
                                    spacing: Theme.spacingS
                                    visible: SessionData.wallpaperCyclingEnabled
                                    leftPadding: Theme.iconSize + Theme.spacingM

                                    Row {
                                        spacing: Theme.spacingL
                                        width: parent.width - parent.leftPadding

                                        StyledText {
                                            text: "Mode:"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        DankTabBar {
                                            id: modeTabBar

                                            width: 200
                                            height: 32
                                            model: [{
                                                "text": "Interval"
                                            }, {
                                                "text": "Time"
                                            }]
                                            currentIndex: SessionData.wallpaperCyclingMode === "time" ? 1 : 0
                                            onTabClicked: (index) => {
                                                SessionData.setWallpaperCyclingMode(index === 1 ? "time" : "interval");
                                            }
                                        }

                                    }

                                    // Interval settings
                                    DankDropdown {
                                        property var intervalOptions: ["1 minute", "5 minutes", "15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours", "3 hours", "4 hours", "6 hours", "8 hours", "12 hours"]
                                        property var intervalValues: [60, 300, 900, 1800, 3600, 5400, 7200, 10800, 14400, 21600, 28800, 43200]

                                        width: parent.width - parent.leftPadding
                                        visible: SessionData.wallpaperCyclingMode === "interval"
                                        text: "Interval"
                                        description: "How often to change wallpaper"
                                        options: intervalOptions
                                        currentValue: {
                                            const currentSeconds = SessionData.wallpaperCyclingInterval;
                                            const index = intervalValues.indexOf(currentSeconds);
                                            return index >= 0 ? intervalOptions[index] : "5 minutes";
                                        }
                                        onValueChanged: (value) => {
                                            const index = intervalOptions.indexOf(value);
                                            if (index >= 0)
                                                SessionData.setWallpaperCyclingInterval(intervalValues[index]);

                                        }
                                    }

                                    // Time settings
                                    Row {
                                        spacing: Theme.spacingM
                                        visible: SessionData.wallpaperCyclingMode === "time"
                                        width: parent.width - parent.leftPadding

                                        StyledText {
                                            text: "Daily at:"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        DankTextField {
                                            width: 100
                                            height: 40
                                            text: SessionData.wallpaperCyclingTime
                                            placeholderText: "00:00"
                                            maximumLength: 5
                                            topPadding: Theme.spacingS
                                            bottomPadding: Theme.spacingS
                                            onAccepted: {
                                                var isValid = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/.test(text);
                                                if (isValid)
                                                    SessionData.setWallpaperCyclingTime(text);
                                                else
                                                    // Reset to current value if invalid
                                                    text = SessionData.wallpaperCyclingTime;
                                            }
                                            onEditingFinished: {
                                                var isValid = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/.test(text);
                                                if (isValid)
                                                    SessionData.setWallpaperCyclingTime(text);
                                                else
                                                    // Reset to current value if invalid
                                                    text = SessionData.wallpaperCyclingTime;
                                            }
                                            anchors.verticalCenter: parent.verticalCenter

                                            validator: RegularExpressionValidator {
                                                regularExpression: /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/
                                            }

                                        }

                                        StyledText {
                                            text: "24-hour format"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

            // Dynamic Theme Section
            StyledRect {
                width: parent.width
                height: dynamicThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: dynamicThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - toggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Dynamic Theming"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically extract colors from wallpaper"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                        }

                        DankToggle {
                            id: toggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: Theme.isDynamicTheme
                            enabled: ToastService.wallpaperErrorStatus !== "matugen_missing"
                            onToggled: (toggled) => {
                                if (toggled)
                                    Theme.switchTheme(10, true);
                                else
                                    Theme.switchTheme(0);
                            }
                        }

                    }

                    StyledText {
                        text: "matugen not detected - dynamic theming unavailable"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.error
                        visible: ToastService.wallpaperErrorStatus === "matugen_missing"
                        width: parent.width
                        leftPadding: Theme.iconSize + Theme.spacingM
                    }

                }

            }


            // TopBar Auto-hide Section
            StyledRect {
                width: parent.width
                height: topBarAutoHideSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: topBarAutoHideSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "visibility_off"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM - autoHideToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "TopBar Auto-hide"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically hide the top bar to expand screen real estate"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                        }

                        DankToggle {
                            id: autoHideToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.topBarAutoHide
                            onToggled: (toggled) => {
                                return SettingsData.setTopBarAutoHide(toggled);
                            }
                        }

                    }

                }

            }

        }

    }

    LazyLoader {
        id: profileBrowserLoader

        active: false

        FileBrowserModal {
            id: profileBrowser

            browserTitle: "Select Profile Image"
            browserIcon: "person"
            browserType: "profile"
            fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
            onFileSelected: (path) => {
                PortalService.setProfileImage(path);
                visible = false;
            }
            onDialogClosed: {
            }
        }

    }

    LazyLoader {
        id: wallpaperBrowserLoader

        active: false

        FileBrowserModal {
            id: wallpaperBrowser

            browserTitle: "Select Wallpaper"
            browserIcon: "wallpaper"
            browserType: "wallpaper"
            fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
            onFileSelected: (path) => {
                SessionData.setWallpaper(path);
                visible = false;
            }
            onDialogClosed: {
            }
        }

    }

}
