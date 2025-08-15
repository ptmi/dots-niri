import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules.ProcessList
import qs.Services
import qs.Widgets

PanelWindow {
  id: processListPopout

  property bool isVisible: false
  property var parentWidget: null
  property real triggerX: Screen.width - 600 - Theme.spacingL
  property real triggerY: Theme.barHeight + Theme.spacingXS
  property real triggerWidth: 55
  property string triggerSection: "right"
  property var triggerScreen: null

  function setTriggerPosition(x, y, width, section, screen) {
    triggerX = x
    triggerY = y
    triggerWidth = width
    triggerSection = section
    triggerScreen = screen
  }

  function hide() {
    isVisible = false
    if (processContextMenu.visible)
      processContextMenu.close()
  }

  function show() {
    isVisible = true
  }

  function toggle() {
    if (isVisible)
      hide()
    else
      show()
  }

  visible: isVisible
  screen: triggerScreen
  implicitWidth: 600
  implicitHeight: 600
  WlrLayershell.layer: WlrLayershell.Overlay
  WlrLayershell.exclusiveZone: -1
  WlrLayershell.keyboardFocus: isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "transparent"

  Ref {
    service: DgopService
  }

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: function (mouse) {
      var localPos = mapToItem(contentLoader, mouse.x, mouse.y)
      if (localPos.x < 0 || localPos.x > contentLoader.width || localPos.y < 0
          || localPos.y > contentLoader.height)
        processListPopout.hide()
    }
  }

  Loader {
    id: contentLoader

    readonly property real screenWidth: processListPopout.screen ? processListPopout.screen.width : Screen.width
    readonly property real screenHeight: processListPopout.screen ? processListPopout.screen.height : Screen.height
    readonly property real targetWidth: Math.min(
                                          600, screenWidth - Theme.spacingL * 2)
    readonly property real targetHeight: Math.min(
                                           600,
                                           screenHeight - Theme.barHeight - Theme.spacingS * 2)
    readonly property real calculatedX: {
      var centerX = processListPopout.triggerX + (processListPopout.triggerWidth
                                                  / 2) - (targetWidth / 2)

      if (centerX >= Theme.spacingM
          && centerX + targetWidth <= screenWidth - Theme.spacingM) {
        return centerX
      }

      if (centerX < Theme.spacingM) {
        return Theme.spacingM
      }

      if (centerX + targetWidth > screenWidth - Theme.spacingM) {
        return screenWidth - targetWidth - Theme.spacingM
      }

      return centerX
    }

    asynchronous: true
    active: processListPopout.isVisible
    width: targetWidth
    height: targetHeight
    y: processListPopout.triggerY
    x: calculatedX
    opacity: processListPopout.isVisible ? 1 : 0
    scale: processListPopout.isVisible ? 1 : 0.9

    Behavior on opacity {
      NumberAnimation {
        duration: Anims.durMed
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasized
      }
    }

    Behavior on scale {
      NumberAnimation {
        duration: Anims.durMed
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasized
      }
    }

    sourceComponent: Rectangle {
      id: dropdownContent

      radius: Theme.cornerRadius
      color: Theme.popupBackground()
      border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                            Theme.outline.b, 0.08)
      border.width: 1
      clip: true
      antialiasing: true
      smooth: true
      focus: true
      Component.onCompleted: {
        if (processListPopout.isVisible)
          forceActiveFocus()
      }
      Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
          processListPopout.hide()
          event.accepted = true
        }
      }

      Connections {
        function onIsVisibleChanged() {
          if (processListPopout.isVisible)
            Qt.callLater(function () {
              dropdownContent.forceActiveFocus()
            })
        }
        target: processListPopout
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingL

        Rectangle {
          Layout.fillWidth: true
          height: systemOverview.height + Theme.spacingM * 2
          radius: Theme.cornerRadius
          color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                         Theme.surfaceVariant.b, 0.2)
          border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                Theme.outline.b, 0.08)
          border.width: 1

          SystemOverview {
            id: systemOverview

            anchors.centerIn: parent
            width: parent.width - Theme.spacingM * 2
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: Theme.cornerRadius
          color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                         Theme.surfaceVariant.b, 0.1)
          border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                Theme.outline.b, 0.05)
          border.width: 1

          ProcessListView {
            anchors.fill: parent
            anchors.margins: Theme.spacingS
            contextMenu: processContextMenu
          }
        }
      }
    }
  }

  ProcessContextMenu {
    id: processContextMenu
  }
}
