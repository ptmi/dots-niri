import QtQuick
import qs.Common

Text {
    id: icon

    property alias name: icon.text
    property alias size: icon.font.pixelSize
    property alias color: icon.color
    property bool filled: false

    font.family: "Material Symbols Rounded"
    font.pixelSize: Theme.iconSize
    font.weight: filled ? Font.Medium : Font.Normal
    color: Theme.surfaceText
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
