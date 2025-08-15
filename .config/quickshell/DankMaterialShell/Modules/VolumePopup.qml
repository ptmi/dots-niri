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
  property bool volumePopupVisible: false

  function show() {
    root.volumePopupVisible = true
    hideTimer.restart()
  }

  function resetHideTimer() {
    if (root.volumePopupVisible)
      hideTimer.restart()
  }

  screen: modelData
  visible: volumePopupVisible
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

    interval: 3000
    repeat: false
    onTriggered: {
      if (!volumePopup.containsMouse)
        root.volumePopupVisible = false
      else
        hideTimer.restart()
    }
  }

  Connections {
    function onVolumeChanged() {
      root.show()
    }

    function onSinkChanged() {
      if (root.volumePopupVisible)
        root.show()
    }

    target: AudioService
  }

  Rectangle {
    id: volumePopup

    property bool containsMouse: popupMouseArea.containsMouse

    width: Math.min(260, Screen.width - Theme.spacingM * 2)
    height: volumeContent.height + Theme.spacingS * 2
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.spacingM
    color: Theme.popupBackground()
    radius: Theme.cornerRadius
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                          Theme.outline.b, 0.08)
    border.width: 1
    opacity: root.volumePopupVisible ? 1 : 0
    scale: root.volumePopupVisible ? 1 : 0.9
    layer.enabled: true

    Column {
      id: volumeContent

      anchors.centerIn: parent
      width: parent.width - Theme.spacingS * 2
      spacing: Theme.spacingXS

      Item {
        property int gap: Theme.spacingS

        width: parent.width
        height: 40

        Rectangle {
          width: Theme.iconSize
          height: Theme.iconSize
          radius: Theme.iconSize / 2
          color: "transparent"
          x: parent.gap
          anchors.verticalCenter: parent.verticalCenter

          DankIcon {
            anchors.centerIn: parent
            name: AudioService.sink && AudioService.sink.audio
                  && AudioService.sink.audio.muted ? "volume_off" : "volume_up"
            size: Theme.iconSize
            color: muteButton.containsMouse ? Theme.primary : Theme.surfaceText
          }

          MouseArea {
            id: muteButton

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AudioService.toggleMute()
              root.resetHideTimer()
            }
          }
        }

        DankSlider {
          id: volumeSlider

          width: parent.width - Theme.iconSize - parent.gap * 3
          height: 40
          x: parent.gap * 2 + Theme.iconSize
          anchors.verticalCenter: parent.verticalCenter
          minimum: 0
          maximum: 100
          enabled: AudioService.sink && AudioService.sink.audio
          showValue: true
          unit: "%"
          Component.onCompleted: {
            if (AudioService.sink && AudioService.sink.audio)
              value = Math.round(AudioService.sink.audio.volume * 100)
          }
          onSliderValueChanged: function (newValue) {
            if (AudioService.sink && AudioService.sink.audio) {
              AudioService.sink.audio.volume = newValue / 100
              root.resetHideTimer()
            }
          }

          Connections {
            function onVolumeChanged() {
              volumeSlider.value = Math.round(
                    AudioService.sink.audio.volume * 100)
            }

            target: AudioService.sink
                    && AudioService.sink.audio ? AudioService.sink.audio : null
          }
        }
      }
    }

    MouseArea {
      id: popupMouseArea

      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      propagateComposedEvents: true
      z: -1
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
      y: root.volumePopupVisible ? 0 : 20
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
    item: volumePopup
  }
}
