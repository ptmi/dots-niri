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
    id: processListDropdown

    property bool isVisible: false
    property var parentWidget: null

    function hide() {
        isVisible = false;
    }

    function show() {
        isVisible = true;
        ProcessMonitorService.updateSystemInfo();
        ProcessMonitorService.updateProcessList();
    }

    function toggle() {
        if (isVisible)
            hide();
        else
            show();
    }

    visible: isVisible
    onIsVisibleChanged: {
        ProcessMonitorService.enableMonitoring(isVisible);
    }
    implicitWidth: 600
    implicitHeight: 600
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

    MouseArea {
        anchors.fill: parent
        onClicked: processListDropdown.hide()
    }

    Rectangle {
        id: dropdownContent

        width: Math.min(600, Screen.width - Theme.spacingL * 2)
        height: Math.min(600, Screen.height - Theme.barHeight - Theme.spacingS * 2)
        x: Math.max(Theme.spacingL, Screen.width - width - Theme.spacingL)
        y: Theme.barHeight + Theme.spacingXS
        radius: Theme.cornerRadiusLarge
        color: Theme.popupBackground()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        clip: true
        opacity: processListDropdown.isVisible ? 1 : 0
        layer.enabled: true
        transform: [
            Scale {
                id: scaleTransform

                origin.x: dropdownContent.width * 0.85
                origin.y: 0
                xScale: processListDropdown.isVisible ? 1 : 0.95
                yScale: processListDropdown.isVisible ? 1 : 0.8

                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

            },
            Translate {
                id: translateTransform

                x: processListDropdown.isVisible ? 0 : 20
                y: processListDropdown.isVisible ? 0 : -30

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

            }
        ]

        MouseArea {

            anchors.fill: parent
            onClicked: {
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            SystemOverview {
                Layout.fillWidth: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            }

            ProcessListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contextMenu: processContextMenuWindow
                processContextMenuWindow: processContextMenuWindow
            }
        }

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
            shadowBlur: 1
            shadowColor: Qt.rgba(0, 0, 0, 0.15)
            shadowOpacity: processListDropdown.isVisible ? 0.15 : 0
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

    }

    ProcessContextMenu {
        id: processContextMenuWindow
    }

}