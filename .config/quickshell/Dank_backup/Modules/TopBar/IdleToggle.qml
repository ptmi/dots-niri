import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property var shell
    width: 30
    height: 30

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (shell) {
                shell.run("~/.config/scripts/toggle_idle.sh")
            } else {
                console.warn("Shell not defined!")
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "☕"
        font.pixelSize: 18
    }
}
