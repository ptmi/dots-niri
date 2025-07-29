import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.Common

ScrollView {
    id: gridView

    property alias model: grid.model
    property int currentIndex: 0
    property int columns: 4
    property bool adaptiveColumns: false
    property int minCellWidth: 120
    property int maxCellWidth: 160
    property int cellPadding: 8
    property real iconSizeRatio: 0.6
    property int maxIconSize: 56
    property int minIconSize: 32
    property real wheelStepSize: 60
    property bool hoverUpdatesSelection: true

    signal itemClicked(int index, var modelData)
    signal itemHovered(int index)

    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    GridView {
        id: grid

        property int baseCellWidth: adaptiveColumns ? Math.max(minCellWidth, Math.min(maxCellWidth, width / columns)) : (width - Theme.spacingS * 2) / columns
        property int baseCellHeight: baseCellWidth + 20
        property int actualColumns: adaptiveColumns ? Math.floor(width / cellWidth) : columns
        property int remainingSpace: width - (actualColumns * cellWidth)

        anchors.fill: parent
        anchors.margins: Theme.spacingS
        cellWidth: baseCellWidth
        cellHeight: baseCellHeight
        leftMargin: Math.max(Theme.spacingS, remainingSpace / 2)
        rightMargin: leftMargin
        focus: true
        interactive: true
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
                grid.contentY -= steps * wheelStepSize;
                if (grid.contentY < 0)
                    grid.contentY = 0;
                else if (grid.contentY > grid.contentHeight - grid.height)
                    grid.contentY = Math.max(0, grid.contentHeight - grid.height);
            }
        }

        delegate: Rectangle {
            width: grid.cellWidth - cellPadding
            height: grid.cellHeight - cellPadding
            radius: Theme.cornerRadiusLarge
            color: currentIndex === index ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16) : mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.03)
            border.color: currentIndex === index ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            border.width: currentIndex === index ? 2 : 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingS

                Item {
                    property int iconSize: Math.min(maxIconSize, Math.max(minIconSize, grid.cellWidth * iconSizeRatio))

                    width: iconSize
                    height: iconSize
                    anchors.horizontalCenter: parent.horizontalCenter

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
                            font.pixelSize: Math.min(28, parent.width * 0.5)
                            color: Theme.primary
                            font.weight: Font.Bold
                        }

                    }

                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: grid.cellWidth - 12
                    text: model.name || ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
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
                        currentIndex = index;

                    itemHovered(index);
                }
                onClicked: {
                    itemClicked(index, model);
                }
            }

        }

    }

}
