import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Notifications.Center

PanelWindow {
  id: root

  property bool notificationHistoryVisible: false
  property real triggerX: Screen.width - 400 - Theme.spacingL
  property real triggerY: Theme.barHeight + Theme.spacingXS
  property real triggerWidth: 40
  property string triggerSection: "right"
  
  NotificationKeyboardController {
    id: keyboardController
    listView: null
    isOpen: notificationHistoryVisible
    onClose: function() { notificationHistoryVisible = false }
  }
  
  NotificationKeyboardHints {
    id: keyboardHints
    anchors.bottom: mainRect.bottom
    anchors.left: mainRect.left
    anchors.right: mainRect.right
    anchors.margins: Theme.spacingL
    showHints: keyboardController.showKeyboardHints
    z: 200
  }

  function setTriggerPosition(x, y, width, section) {
    triggerX = x
    triggerY = y
    triggerWidth = width
    triggerSection = section
  }

  visible: notificationHistoryVisible
  onNotificationHistoryVisibleChanged: {
    NotificationService.disablePopups(notificationHistoryVisible)
  }
  implicitWidth: 400
  implicitHeight: Math.min(Screen.height * 0.8, 400)
  WlrLayershell.layer: WlrLayershell.Overlay
  WlrLayershell.exclusiveZone: -1
  WlrLayershell.keyboardFocus: notificationHistoryVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "transparent"

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      notificationHistoryVisible = false
    }
  }

  Rectangle {
    id: mainRect

    readonly property real popupWidth: 400
    readonly property real calculatedX: {
      var centerX = root.triggerX + (root.triggerWidth / 2) - (popupWidth / 2)

      if (centerX >= Theme.spacingM
          && centerX + popupWidth <= Screen.width - Theme.spacingM) {
        return centerX
      }

      if (centerX < Theme.spacingM) {
        return Theme.spacingM
      }

      if (centerX + popupWidth > Screen.width - Theme.spacingM) {
        return Screen.width - popupWidth - Theme.spacingM
      }

      return centerX
    }

    width: popupWidth
    height: {
      let baseHeight = Theme.spacingL * 2
      baseHeight += notificationHeader.height
      // Use the final content height when expanded, not the animating height
      baseHeight += (notificationSettings.expanded ? notificationSettings.contentHeight : 0)
      baseHeight += Theme.spacingM * 2
      let listHeight = notificationList.listContentHeight
      if (NotificationService.groupedNotifications.length === 0)
        listHeight = 200

      baseHeight += Math.min(listHeight, 600)
      return Math.max(300, Math.min(baseHeight, Screen.height * 0.8))
    }
    x: calculatedX
    y: root.triggerY
    color: Theme.popupBackground()
    radius: Theme.cornerRadius
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                          Theme.outline.b, 0.08)
    border.width: 1
    opacity: notificationHistoryVisible ? 1 : 0
    scale: notificationHistoryVisible ? 1 : 0.9

    MouseArea {
      anchors.fill: parent
      onClicked: {

      }
    }

    FocusScope {
      id: contentColumn

      anchors.fill: parent
      anchors.margins: Theme.spacingL
      focus: true
      
      Component.onCompleted: {
        if (notificationHistoryVisible)
          forceActiveFocus()
      }
      
      Keys.onPressed: function(event) {
        keyboardController.handleKey(event)
      }
      
      Column {
        id: contentColumnInner
        anchors.fill: parent
        spacing: Theme.spacingM

      Connections {
        function onNotificationHistoryVisibleChanged() {
          if (notificationHistoryVisible)
            Qt.callLater(function () {
              contentColumn.forceActiveFocus()
            })
          else
            contentColumn.focus = false
        }
        target: root
      }

      NotificationHeader {
        id: notificationHeader
        keyboardController: keyboardController
      }
      
      NotificationSettings {
        id: notificationSettings
        expanded: notificationHeader.showSettings
      }

      KeyboardNavigatedNotificationList {
        id: notificationList

        width: parent.width
        height: parent.height - notificationHeader.height - notificationSettings.height - contentColumnInner.spacing * 2
        
        Component.onCompleted: {
          if (keyboardController && notificationList) {
            keyboardController.listView = notificationList
            notificationList.keyboardController = keyboardController
          }
        }
      }
      
      }
    }


    Behavior on height {
      NumberAnimation {
        duration: Anims.durShort
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasized
      }
    }

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
  }
}
