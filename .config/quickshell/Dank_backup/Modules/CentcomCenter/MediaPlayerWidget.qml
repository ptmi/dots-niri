import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: mediaPlayerWidget

    property MprisPlayer activePlayer: MprisController.activePlayer
    property string lastValidTitle: ""
    property string lastValidArtist: ""
    property string lastValidAlbum: ""
    property string lastValidArtUrl: ""
    property real currentPosition: 0

    // Simple progress ratio calculation
    function ratio() {
        return activePlayer && activePlayer.length > 0 ? currentPosition / activePlayer.length : 0;
    }

    onActivePlayerChanged: {
        if (!activePlayer)
            updateTimer.start();
        else
            updateTimer.stop();
    }
    width: parent.width
    height: parent.height
    radius: Theme.cornerRadiusLarge
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    border.width: 1
    layer.enabled: true

    Timer {
        id: updateTimer

        interval: 2000
        running: {
            // Run when no active player (for cache clearing) OR when playing (for position updates)
            return (!activePlayer) || (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing && activePlayer.length > 0 && !progressMouseArea.isSeeking);
        }
        repeat: true
        onTriggered: {
            if (!activePlayer) {
                // Clear cache when no player
                lastValidTitle = "";
                lastValidArtist = "";
                lastValidAlbum = "";
                lastValidArtUrl = "";
                stop(); // Stop after clearing cache
            } else if (activePlayer.playbackState === MprisPlaybackState.Playing && !progressMouseArea.isSeeking) {
                // Update position when playing
                currentPosition = activePlayer.position;
            }
        }
    }

    // Backend events
    Connections {
        function onPositionChanged() {
            if (!progressMouseArea.isSeeking)
                currentPosition = activePlayer.position;

        }

        function onPostTrackChanged() {
            currentPosition = activePlayer && activePlayer.position || 0;
        }

        function onTrackTitleChanged() {
            currentPosition = activePlayer && activePlayer.position || 0;
        }

        target: activePlayer
    }

    Item {
        anchors.fill: parent
        anchors.margins: Theme.spacingS

        // Placeholder when no media - centered in entire widget
        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingS
            visible: (!activePlayer && !lastValidTitle) || (activePlayer && activePlayer.trackTitle === "" && lastValidTitle === "")

            DankIcon {
                name: "music_note"
                size: Theme.iconSize + 8
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "No Media Playing"
                font.pixelSize: Theme.fontSizeMedium
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

        // Active content in a column
        Column {
            anchors.fill: parent
            spacing: Theme.spacingS
            visible: activePlayer && activePlayer.trackTitle !== "" || lastValidTitle !== ""

            // Normal media info when playing
            Row {
                width: parent.width
                height: 60
                spacing: Theme.spacingM

                // Album Art
                Rectangle {
                    width: 60
                    height: 60
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Item {
                        anchors.fill: parent
                        clip: true

                        Image {
                            id: albumArt

                            anchors.fill: parent
                            source: activePlayer && activePlayer.trackArtUrl || lastValidArtUrl || ""
                            onSourceChanged: {
                                if (activePlayer && activePlayer.trackArtUrl)
                                    lastValidArtUrl = activePlayer.trackArtUrl;

                            }
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: albumArt.status !== Image.Ready
                            color: "transparent"

                            DankIcon {
                                anchors.centerIn: parent
                                name: "album"
                                size: 28
                                color: Theme.surfaceVariantText
                            }

                        }

                    }

                }

                // Track Info
                Column {
                    width: parent.width - 60 - Theme.spacingM
                    height: parent.height
                    spacing: Theme.spacingXS

                    Text {
                        text: activePlayer && activePlayer.trackTitle || lastValidTitle || "Unknown Track"
                        onTextChanged: {
                            if (activePlayer && activePlayer.trackTitle)
                                lastValidTitle = activePlayer.trackTitle;

                        }
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: activePlayer && activePlayer.trackArtist || lastValidArtist || "Unknown Artist"
                        onTextChanged: {
                            if (activePlayer && activePlayer.trackArtist)
                                lastValidArtist = activePlayer.trackArtist;

                        }
                        font.pixelSize: Theme.fontSizeSmall
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.8)
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: activePlayer && activePlayer.trackAlbum || lastValidAlbum || ""
                        onTextChanged: {
                            if (activePlayer && activePlayer.trackAlbum)
                                lastValidAlbum = activePlayer.trackAlbum;

                        }
                        font.pixelSize: Theme.fontSizeSmall
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                        width: parent.width
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }

                }

            }

            // Progress bar
            Item {
                id: progressBarContainer

                width: parent.width
                height: 24

                Rectangle {
                    id: progressBarBackground

                    width: parent.width
                    height: 6
                    radius: 3
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    visible: activePlayer !== null
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: progressFill

                        height: parent.height
                        radius: parent.radius
                        color: Theme.primary
                        width: parent.width * ratio()

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                            }

                        }

                    }

                    // Drag handle
                    Rectangle {
                        id: progressHandle

                        width: 12
                        height: 12
                        radius: 6
                        color: Theme.primary
                        border.color: Qt.lighter(Theme.primary, 1.3)
                        border.width: 1
                        x: Math.max(0, Math.min(parent.width - width, progressFill.width - width / 2))
                        anchors.verticalCenter: parent.verticalCenter
                        visible: activePlayer && activePlayer.length > 0
                        scale: progressMouseArea.containsMouse || progressMouseArea.pressed ? 1.2 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                            }

                        }

                    }

                }

                MouseArea {
                    id: progressMouseArea

                    property bool isSeeking: false

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: activePlayer && activePlayer.length > 0 && activePlayer.canSeek
                    preventStealing: true
                    onPressed: function(mouse) {
                        isSeeking = true;
                        if (activePlayer && activePlayer.length > 0) {
                            let ratio = Math.max(0, Math.min(1, mouse.x / progressBarBackground.width));
                            let seekPosition = ratio * activePlayer.length;
                            activePlayer.position = seekPosition;
                            currentPosition = seekPosition;
                        }
                    }
                    onReleased: {
                        isSeeking = false;
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed && isSeeking && activePlayer && activePlayer.length > 0) {
                            let ratio = Math.max(0, Math.min(1, mouse.x / progressBarBackground.width));
                            let seekPosition = ratio * activePlayer.length;
                            activePlayer.position = seekPosition;
                            currentPosition = seekPosition;
                        }
                    }
                    onClicked: function(mouse) {
                        if (activePlayer && activePlayer.length > 0) {
                            let ratio = Math.max(0, Math.min(1, mouse.x / progressBarBackground.width));
                            let seekPosition = ratio * activePlayer.length;
                            activePlayer.position = seekPosition;
                            currentPosition = seekPosition;
                        }
                    }
                }

                // Global mouse area for drag tracking
                MouseArea {
                    id: progressGlobalMouseArea

                    x: 0
                    y: 0
                    width: mediaPlayerWidget.width
                    height: mediaPlayerWidget.height
                    enabled: progressMouseArea.isSeeking
                    visible: false
                    preventStealing: true
                    onPositionChanged: function(mouse) {
                        if (progressMouseArea.isSeeking && activePlayer && activePlayer.length > 0) {
                            let globalPos = mapToItem(progressBarBackground, mouse.x, mouse.y);
                            let ratio = Math.max(0, Math.min(1, globalPos.x / progressBarBackground.width));
                            let seekPosition = ratio * activePlayer.length;
                            activePlayer.position = seekPosition;
                            currentPosition = seekPosition;
                        }
                    }
                    onReleased: {
                        progressMouseArea.isSeeking = false;
                    }
                }

            }

            // Control buttons - always visible
            Item {
                width: parent.width
                height: 32
                visible: activePlayer !== null

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingM
                    height: parent.height

                    // Previous button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: prevBtnArea.containsMouse ? Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.12) : "transparent"

                        DankIcon {
                            anchors.centerIn: parent
                            name: "skip_previous"
                            size: 16
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: prevBtnArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!activePlayer)
                                    return ;

                                // >8 s → jump to start, otherwise previous track
                                if (currentPosition > 8 && activePlayer.canSeek) {
                                    activePlayer.position = 0;
                                    currentPosition = 0;
                                } else {
                                    activePlayer.previous();
                                }
                            }
                        }

                    }

                    // Play/Pause button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Theme.primary

                        DankIcon {
                            anchors.centerIn: parent
                            name: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
                            size: 20
                            color: Theme.background
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activePlayer && activePlayer.togglePlaying()
                        }

                    }

                    // Next button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: nextBtnArea.containsMouse ? Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.12) : "transparent"

                        DankIcon {
                            anchors.centerIn: parent
                            name: "skip_next"
                            size: 16
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: nextBtnArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activePlayer && activePlayer.next()
                        }

                    }

                }

            }

        }

    }

    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 2
        shadowBlur: 0.5
        shadowColor: Qt.rgba(0, 0, 0, 0.1)
        shadowOpacity: 0.1
    }

}
