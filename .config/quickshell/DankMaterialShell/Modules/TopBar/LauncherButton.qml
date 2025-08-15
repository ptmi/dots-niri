import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  property bool isActive: false
  property string section: "left" // Which section this button is in
  property var popupTarget: null // Reference to the popup to position
  property var parentScreen: null // The screen this button is on

  signal clicked

  width: 40
  height: 30
  radius: Theme.cornerRadius
  color: {
    const baseColor = launcherArea.containsMouse
                    || isActive ? Theme.surfaceTextPressed : Theme.surfaceTextHover
    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b,
                   baseColor.a * Theme.widgetTransparency)
  }

  SystemLogo {
    visible: SettingsData.useOSLogo
    anchors.centerIn: parent
    width: Theme.iconSize - 3
    height: Theme.iconSize - 3
    colorOverride: SettingsData.osLogoColorOverride
    brightnessOverride: SettingsData.osLogoBrightness
    contrastOverride: SettingsData.osLogoContrast
  }

  DankIcon {
    visible: !SettingsData.useOSLogo
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
    onClicked: {
      if (popupTarget && popupTarget.setTriggerPosition) {
        var globalPos = mapToGlobal(0, 0)
        var currentScreen = parentScreen || Screen
        var screenX = currentScreen.x || 0
        var relativeX = globalPos.x - screenX
        popupTarget.setTriggerPosition(relativeX,
                                       Theme.barHeight + Theme.spacingXS,
                                       width, section, currentScreen)
      }
      root.clicked()
    }
  }

  Behavior on color {
    ColorAnimation {
      duration: Theme.shortDuration
      easing.type: Theme.standardEasing
    }
  }
}
