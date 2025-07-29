import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property string text: ""
    property string description: ""
    property string currentValue: ""
    property var options: []

    signal valueChanged(string value)

    width: parent.width
    height: 60
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)
    // Global keyboard handler for escape key
    Keys.onEscapePressed: {
        if (dropdownMenu.visible)
            dropdownMenu.visible = false;

    }

    Column {
        anchors.left: parent.left
        anchors.right: dropdown.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spacingM
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingXS

        Text {
            text: root.text
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            font.weight: Font.Medium
        }

        Text {
            text: root.description
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            visible: description.length > 0
            wrapMode: Text.WordWrap
            width: parent.width
        }

    }

    Rectangle {
        id: dropdown

        width: 180
        height: 36
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        radius: Theme.cornerRadiusSmall
        color: dropdownArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Theme.contentBackground()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingS

            Text {
                text: root.currentValue
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 24
                elide: Text.ElideRight
            }

            DankIcon {
                name: "expand_more"
                size: 20
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        MouseArea {
            id: dropdownArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => {
                mouse.accepted = true;
                if (!dropdownMenu.visible) {
                    dropdownMenu.updatePosition();
                    dropdownMenu.visible = true;
                } else {
                    dropdownMenu.visible = false;
                }
            }
        }

    }

    // Integrated dropdown menu with full-screen overlay
    PanelWindow {
        id: dropdownMenu

        property int targetX: 0
        property int targetY: 0

        function updatePosition() {
            var globalPos = dropdown.mapToGlobal(0, 0);
            targetX = globalPos.x;
            targetY = globalPos.y + dropdown.height + 4;
        }

        visible: false
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

        // Background click interceptor (invisible)
        MouseArea {
            anchors.fill: parent
            z: -1
            onPressed: {
                dropdownMenu.visible = false;
            }
        }

        // Dropdown menu content
        Rectangle {
            x: dropdownMenu.targetX
            y: dropdownMenu.targetY
            width: 180
            height: Math.min(200, root.options.length * 36 + 16)
            radius: Theme.cornerRadiusSmall
            color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 1)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
            border.width: 1

            ScrollView {
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                clip: true

                ListView {
                    model: root.options
                    spacing: 2

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 32
                        radius: Theme.cornerRadiusSmall
                        color: optionArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            font.pixelSize: Theme.fontSizeMedium
                            color: root.currentValue === modelData ? Theme.primary : Theme.surfaceText
                            font.weight: root.currentValue === modelData ? Font.Medium : Font.Normal
                        }

                        MouseArea {
                            id: optionArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: {
                                root.currentValue = modelData;
                                root.valueChanged(modelData);
                                dropdownMenu.visible = false;
                            }
                        }

                    }

                }

            }

        }

    }

}
