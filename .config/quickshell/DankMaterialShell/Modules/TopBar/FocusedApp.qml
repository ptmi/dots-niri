import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  property bool compactMode: false
  property int availableWidth: 400
  readonly property int baseWidth: contentRow.implicitWidth + Theme.spacingS * 2
  readonly property int maxNormalWidth: 456
  readonly property int maxCompactWidth: 288

  width: compactMode ? Math.min(baseWidth,
                                maxCompactWidth) : Math.min(baseWidth,
                                                            maxNormalWidth)
  height: 30
  radius: Theme.cornerRadius
  color: {
    if (!FocusedWindowService.focusedAppName
        && !FocusedWindowService.focusedWindowTitle)
      return "transparent"

    const baseColor = mouseArea.containsMouse ? Theme.primaryHover : Theme.surfaceTextHover
    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b,
                   baseColor.a * Theme.widgetTransparency)
  }
  clip: true
  visible: FocusedWindowService.niriAvailable
           && (FocusedWindowService.focusedAppName
               || FocusedWindowService.focusedWindowTitle)

  Row {
    id: contentRow

    anchors.centerIn: parent
    spacing: Theme.spacingS

    StyledText {
      id: appText

      text: FocusedWindowService.focusedAppName || ""
      font.pixelSize: Theme.fontSizeSmall
      font.weight: Font.Medium
      color: Theme.surfaceText
      anchors.verticalCenter: parent.verticalCenter
      elide: Text.ElideRight
      maximumLineCount: 1
      width: Math.min(implicitWidth, compactMode ? 80 : 180)
    }

    StyledText {
      text: "•"
      font.pixelSize: Theme.fontSizeSmall
      color: Theme.outlineButton
      anchors.verticalCenter: parent.verticalCenter
      visible: appText.text && titleText.text
    }

    StyledText {
      id: titleText

      text: FocusedWindowService.focusedWindowTitle || ""
      font.pixelSize: Theme.fontSizeSmall
      font.weight: Font.Medium
      color: Theme.surfaceText
      anchors.verticalCenter: parent.verticalCenter
      elide: Text.ElideRight
      maximumLineCount: 1
      width: Math.min(implicitWidth, compactMode ? 180 : 250)
      visible: text.length > 0
    }
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    hoverEnabled: true
  }

  Behavior on color {
    ColorAnimation {
      duration: Theme.shortDuration
      easing.type: Theme.standardEasing
    }
  }

  Behavior on width {
    NumberAnimation {
      duration: Theme.shortDuration
      easing.type: Theme.standardEasing
    }
  }
}
