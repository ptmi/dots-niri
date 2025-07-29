import QtQuick
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property string iconName: ""
    property int iconSize: Theme.iconSize - 4
    property color iconColor: Theme.surfaceText
    property color hoverColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
    property color backgroundColor: "transparent"
    property bool circular: true
    property int buttonSize: 32

    signal clicked()

    width: buttonSize
    height: buttonSize
    radius: circular ? buttonSize / 2 : Theme.cornerRadius
    color: mouseArea.containsMouse ? hoverColor : backgroundColor

    DankIcon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.iconSize
        color: root.iconColor
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }

    }

}
