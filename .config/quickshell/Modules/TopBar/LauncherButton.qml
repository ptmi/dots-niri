import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool isActive: false

    signal clicked()

    width: 40
    height: 30
    radius: Theme.cornerRadius
    color: launcherArea.containsMouse || isActive ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.12) : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08)

    SystemLogo {
        visible: Prefs.useOSLogo
        anchors.centerIn: parent
        width: Theme.iconSize - 3
        height: Theme.iconSize - 3
        colorOverride: Prefs.osLogoColorOverride
        brightnessOverride: Prefs.osLogoBrightness
        contrastOverride: Prefs.osLogoContrast
    }

    DankIcon {
        visible: !Prefs.useOSLogo
        anchors.centerIn: parent
        name: "apps"
        size: Theme.iconSize - 6
        color: Theme.surfaceText
    }

    MouseArea {
        id: launcherArea

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
