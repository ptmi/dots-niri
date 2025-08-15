import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    visible: ToastService.toastVisible
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
        id: toast

        width: Math.min(400, Screen.width - Theme.spacingL * 2)
        height: toastContent.height + Theme.spacingL * 2
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.barHeight + Theme.spacingL
        color: {
            switch (ToastService.currentLevel) {
            case ToastService.levelError:
                return Theme.error;
            case ToastService.levelWarn:
                return Theme.warning;
            case ToastService.levelInfo:
                return Theme.primary;
            default:
                return Theme.primary;
            }
        }
        radius: Theme.cornerRadiusLarge
        layer.enabled: true
        opacity: ToastService.toastVisible ? 0.9 : 0
        scale: ToastService.toastVisible ? 1 : 0.9

        Row {
            id: toastContent

            anchors.centerIn: parent
            spacing: Theme.spacingM

            DankIcon {
                name: {
                    switch (ToastService.currentLevel) {
                    case ToastService.levelError:
                        return "error";
                    case ToastService.levelWarn:
                        return "warning";
                    case ToastService.levelInfo:
                        return "info";
                    default:
                        return "info";
                    }
                }
                size: Theme.iconSize
                color: Theme.background
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: ToastService.currentMessage
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.background
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
                width: 300
                wrapMode: Text.WordWrap
            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: ToastService.hideToast()
        }

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 4
            shadowBlur: 0.8
            shadowColor: Qt.rgba(0, 0, 0, 0.3)
            shadowOpacity: 0.3
        }

        transform: Translate {
            y: ToastService.toastVisible ? 0 : -20
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }

        }

    }

    // Makes the background transparent to mouse events
    mask: Region {
        item: toast
    }

}
