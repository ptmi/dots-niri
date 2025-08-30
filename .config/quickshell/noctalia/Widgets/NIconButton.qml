import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons
import qs.Services

Rectangle {
  id: root

  // Multiplier to control how large the button container is relative to Style.baseWidgetSize
  property real sizeRatio: 1.0
  readonly property real size: Style.baseWidgetSize * sizeRatio * scaling

  property string icon
  property string tooltipText
  property bool enabled: true
  property bool hovering: false
  property real fontPointSize: Style.fontSizeM

  property color colorBg: Color.mSurfaceVariant
  property color colorFg: Color.mPrimary
  property color colorBgHover: Color.mPrimary
  property color colorFgHover: Color.mOnPrimary
  property color colorBorder: Color.mOutline
  property color colorBorderHover: Color.mOutline

  signal entered
  signal exited
  signal clicked

  implicitWidth: size
  implicitHeight: size

  color: root.hovering ? colorBgHover : colorBg
  radius: width * 0.5
  border.color: root.hovering ? colorBorderHover : colorBorder
  border.width: Math.max(1, Style.borderS * scaling)

  NIcon {
    text: root.icon
    font.pointSize: root.fontPointSize * scaling
    color: root.hovering ? colorFgHover : colorFg
    opacity: root.enabled ? Style.opacityFull : Style.opacityMedium
    // Center horizontally
    x: (root.width - width) / 2
    // Center vertically accounting for font metrics
    y: (root.height - height) / 2 + (height - contentHeight) / 2
  }

  NTooltip {
    id: tooltip
    target: root
    positionAbove: Settings.data.bar.position === "bottom"
    text: root.tooltipText
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: {
      hovering = true
      if (tooltipText) {
        tooltip.show()
      }
      root.entered()
    }
    onExited: {
      hovering = false
      if (tooltipText) {
        tooltip.hide()
      }
      root.exited()
    }
    onClicked: {
      if (tooltipText) {
        tooltip.hide()
      }
      root.clicked()
    }
  }
}
