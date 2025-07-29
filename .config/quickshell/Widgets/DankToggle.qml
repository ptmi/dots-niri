import QtQuick
import qs.Common

Item {
    id: toggle

    property bool checked: false
    property bool enabled: true
    property bool toggling: false
    property string text: ""
    property string description: ""

    signal clicked()
    signal toggled(bool checked)

    width: text ? parent.width : 48
    height: text ? 60 : 24

    Rectangle {
        id: background

        anchors.fill: parent
        radius: toggle.text ? Theme.cornerRadius : 0
        color: toggle.text ? (toggleArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)) : "transparent"
        visible: toggle.text
    }

    Row {
        id: textRow

        anchors.left: parent.left
        anchors.right: toggleTrack.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spacingM
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingXS
        visible: toggle.text

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXS

            Text {
                text: toggle.text
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            Text {
                text: toggle.description
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: Math.min(implicitWidth, toggle.width - 120)
                visible: toggle.description.length > 0
            }

        }

    }

    Rectangle {
        id: toggleTrack

        width: toggle.text ? 48 : parent.width
        height: toggle.text ? 24 : parent.height
        anchors.right: parent.right
        anchors.rightMargin: toggle.text ? Theme.spacingM : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: toggle.checked ? Theme.primary : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
        opacity: toggle.toggling ? 0.6 : 1

        Rectangle {
            id: toggleHandle

            width: 20
            height: 20
            radius: 10
            color: Theme.surface
            anchors.verticalCenter: parent.verticalCenter
            x: toggle.checked ? parent.width - width - 2 : 2

            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: (parent.width + 2) / 2
                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.1)
                border.width: 1
                z: -1
            }

            Behavior on x {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.emphasizedEasing
                }

            }

        }

    }

    MouseArea {
        id: toggleArea

        anchors.fill: toggle.text ? toggle : toggleTrack
        hoverEnabled: true
        cursorShape: toggle.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: toggle.enabled
        onClicked: {
            toggle.checked = !toggle.checked;
            toggle.clicked();
            toggle.toggled(toggle.checked);
        }
    }

}
