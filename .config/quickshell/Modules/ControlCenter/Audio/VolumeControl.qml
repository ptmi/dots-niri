import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Column {
    id: root
    
    property real volumeLevel: (AudioService.sink && AudioService.sink.audio && AudioService.sink.audio.volume * 100) || 0
    property bool volumeMuted: (AudioService.sink && AudioService.sink.audio && AudioService.sink.audio.muted) || false
    
    width: parent.width
    spacing: Theme.spacingM

    Text {
        text: "Volume"
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.surfaceText
        font.weight: Font.Medium
    }

    Row {
        width: parent.width
        spacing: Theme.spacingM

        DankIcon {
            name: root.volumeMuted ? "volume_off" : "volume_down"
            size: Theme.iconSize
            color: root.volumeMuted ? Theme.error : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (AudioService.sink && AudioService.sink.audio)
                        AudioService.sink.audio.muted = !AudioService.sink.audio.muted;
                }
            }
        }

        Item {
            id: volumeSliderContainer

            width: parent.width - 80
            height: 32
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: volumeSliderTrack

                width: parent.width
                height: 8
                radius: 4
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: volumeSliderFill

                    width: parent.width * (root.volumeLevel / 100)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                Rectangle {
                    id: volumeHandle

                    width: 18
                    height: 18
                    radius: 9
                    color: Theme.primary
                    border.color: Qt.lighter(Theme.primary, 1.3)
                    border.width: 2
                    x: Math.max(0, Math.min(parent.width - width, volumeSliderFill.width - width / 2))
                    anchors.verticalCenter: parent.verticalCenter
                    scale: volumeMouseArea.containsMouse || volumeMouseArea.pressed ? 1.2 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }

            MouseArea {
                id: volumeMouseArea

                property bool isDragging: false

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                onPressed: (mouse) => {
                    isDragging = true;
                    let ratio = Math.max(0, Math.min(1, mouse.x / volumeSliderTrack.width));
                    let newVolume = Math.round(ratio * 100);
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = false;
                        AudioService.sink.audio.volume = newVolume / 100;
                    }
                }
                onReleased: {
                    isDragging = false;
                }
                onPositionChanged: (mouse) => {
                    if (pressed && isDragging) {
                        let ratio = Math.max(0, Math.min(1, mouse.x / volumeSliderTrack.width));
                        let newVolume = Math.round(ratio * 100);
                        if (AudioService.sink && AudioService.sink.audio) {
                            AudioService.sink.audio.muted = false;
                            AudioService.sink.audio.volume = newVolume / 100;
                        }
                    }
                }
                onClicked: (mouse) => {
                    let ratio = Math.max(0, Math.min(1, mouse.x / volumeSliderTrack.width));
                    let newVolume = Math.round(ratio * 100);
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = false;
                        AudioService.sink.audio.volume = newVolume / 100;
                    }
                }
            }

            MouseArea {
                id: volumeGlobalMouseArea

                x: 0
                y: 0
                width: root.parent ? root.parent.width : 0
                height: root.parent ? root.parent.height : 0
                enabled: volumeMouseArea.isDragging
                visible: false
                preventStealing: true
                onPositionChanged: (mouse) => {
                    if (volumeMouseArea.isDragging) {
                        let globalPos = mapToItem(volumeSliderTrack, mouse.x, mouse.y);
                        let ratio = Math.max(0, Math.min(1, globalPos.x / volumeSliderTrack.width));
                        let newVolume = Math.round(ratio * 100);
                        if (AudioService.sink && AudioService.sink.audio) {
                            AudioService.sink.audio.muted = false;
                            AudioService.sink.audio.volume = newVolume / 100;
                        }
                    }
                }
                onReleased: {
                    volumeMouseArea.isDragging = false;
                }
            }
        }

        DankIcon {
            name: "volume_up"
            size: Theme.iconSize
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}