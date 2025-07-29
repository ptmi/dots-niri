import QtQuick 2.15
import Quickshell
import Quickshell.Io
import qs.Common 1.0
import qs.Widgets 1.0

Rectangle {
    id: root
    width: 40
    height: 30
    radius: Theme.cornerRadius
    color: mouseArea.containsMouse
    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
    : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08)
    anchors.verticalCenter: parent.verticalCenter

    property bool inhibitorOn: false

    Process {
        id: shellProcess
        onExited: {
            inhibitorOn = !inhibitorOn
            console.log("Idle inhibitor toggled. Now:", inhibitorOn)
        }

    }

    Process {
        id: checkProcess
        onExited: {
            inhibitorOn = (exitCode === 0)
            console.log("Initial inhibitor state:", inhibitorOn)
        }
    }

    Component.onCompleted: {
        checkProcess.exec(["/home/ptmi/.local/bin/is-inhibited.sh"])
    }

    DankIcon {
        anchors.centerIn: parent
        name: inhibitorOn ? "bedtime" : "bedtime_off"
        size: 20
        color: "#cdd6f4"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            shellProcess.exec(["/home/ptmi/.local/bin/toggle-inhibit.sh"])
        }
    }
}
