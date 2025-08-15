import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
  id: root

  property var modelData
  property bool micPopupVisible: false

  function show() {
    root.micPopupVisible = true
    hideTimer.restart()
  }

  screen: modelData
  visible: micPopupVisible
  WlrLayershell.layer: WlrLayershell.Overlay
  WlrLayershell.exclusiveZone: -1
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  color: "transparent"

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  Timer {
    id: hideTimer

    interval: 2000
    repeat: false
    onTriggered: {
      root.micPopupVisible = false
    }
  }

  Connections {
    function onMicMuteChanged() {
      root.show()
    }

    target: AudioService
  }

  Rectangle {
    id: micPopup

    width: Theme.iconSize + Theme.spacingS * 2
    height: Theme.iconSize + Theme.spacingS * 2
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.spacingM
    color: Theme.popupBackground()
    radius: Theme.cornerRadius
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                          Theme.outline.b, 0.08)
    border.width: 1
    opacity: root.micPopupVisible ? 1 : 0
    scale: root.micPopupVisible ? 1 : 0.9
    layer.enabled: true

    DankIcon {
      id: micContent

      anchors.centerIn: parent
      name: AudioService.source && AudioService.source.audio
            && AudioService.source.audio.muted ? "mic_off" : "mic"
      size: Theme.iconSize
      color: AudioService.source && AudioService.source.audio
             && AudioService.source.audio.muted ? Theme.error : Theme.primary
    }

    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowHorizontalOffset: 0
      shadowVerticalOffset: 4
      shadowBlur: 0.8
      shadowColor: Qt.rgba(0, 0, 0, 0.3)
      shadowOpacity: 0.3
    }

    transform: Translate {
      y: root.micPopupVisible ? 0 : 20
    }

    Behavior on opacity {
      NumberAnimation {
        duration: Theme.mediumDuration
        easing.type: Theme.emphasizedEasing
      }
    }

    Behavior on scale {
      NumberAnimation {
        duration: Theme.mediumDuration
        easing.type: Theme.emphasizedEasing
      }
    }

    Behavior on transform {
      PropertyAnimation {
        duration: Theme.mediumDuration
        easing.type: Theme.emphasizedEasing
      }
    }
  }

  mask: Region {
    item: micPopup
  }
}
