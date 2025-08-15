import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.Common

ScrollView {
    id: listView

    property alias model: list.model
    property int currentIndex: 0
    property int itemHeight: 72
    property int iconSize: 56
    property real wheelStepSize: 60
    property bool showDescription: true
    property int itemSpacing: Theme.spacingS
    property bool hoverUpdatesSelection: true

    signal itemClicked(int index, var modelData)
    signal itemHovered(int index)

    clip: true
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: itemSpacing
        spacing: listView.itemSpacing
        focus: true
        interactive: true
        currentIndex: listView.currentIndex
        flickDeceleration: 8000
        maximumFlickVelocity: 15000

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            z: -1
            onWheel: function(wheel) {
                var delta = wheel.angleDelta.y;
                var steps = delta / 120;
                list.contentY -= steps * wheelStepSize;
                if (list.contentY < 0)
                    list.contentY = 0;
                else if (list.contentY > list.contentHeight - list.height)
                    list.contentY = Math.max(0, list.contentHeight - list.height);
            }
        }

        delegate: Rectangle {
            width: list.width
            height: itemHeight
            radius: Theme.cornerRadiusLarge
            color: ListView.isCurrentItem ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16) : mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.03)
            border.color: ListView.isCurrentItem ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            border.width: ListView.isCurrentItem ? 2 : 1

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingL

                Item {
                    width: iconSize
                    height: iconSize
                    anchors.verticalCenter: parent.verticalCenter

                    IconImage {
                        id: iconImg

                        anchors.fill: parent
                        source: (model.icon) ? Quickshell.iconPath(model.icon, "") : ""
                        smooth: true
                        asynchronous: true
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: !iconImg.visible
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                        radius: Theme.cornerRadiusLarge
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)

                        Text {
                            anchors.centerIn: parent
                            text: (model.name && model.name.length > 0) ? model.name.charAt(0).toUpperCase() : "A"
                            font.pixelSize: iconSize * 0.4
                            color: Theme.primary
                            font.weight: Font.Bold
                        }

                    }

                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - iconSize - Theme.spacingL
                    spacing: Theme.spacingXS

                    Text {
                        width: parent.width
                        text: model.name || ""
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: model.comment || "Application"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        elide: Text.ElideRight
                        visible: showDescription && model.comment && model.comment.length > 0
                    }

                }

            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 10
                onEntered: {
                    if (hoverUpdatesSelection)
                        listView.currentIndex = index;

                    itemHovered(index);
                }
                onClicked: {
                    itemClicked(index, model);
                }
            }

        }

    }

}
