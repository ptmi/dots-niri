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
  property bool brightnessPopupVisible: false
  property var brightnessDebounceTimer

  brightnessDebounceTimer: Timer {
    property int pendingValue: 0

    interval: BrightnessService.ddcAvailable ? 500 : 50
    repeat: false
    onTriggered: {
      BrightnessService.setBrightnessInternal(pendingValue, BrightnessService.lastIpcDevice)
    }
  }

  function show() {
    root.brightnessPopupVisible = true
    // Update slider to current device brightness when showing
    if (BrightnessService.brightnessAvailable) {
      brightnessSlider.value = BrightnessService.brightnessLevel
    }
    hideTimer.restart()
  }

  function resetHideTimer() {
    if (root.brightnessPopupVisible)
      hideTimer.restart()
  }

  screen: modelData
  visible: brightnessPopupVisible
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
      if (!brightnessPopup.containsMouse)
        root.brightnessPopupVisible = false
      else
        hideTimer.restart()
    }
  }

  Connections {
    function onBrightnessChanged() {
      root.show()
    }

    target: BrightnessService
  }

  Rectangle {
    id: brightnessPopup

    property bool containsMouse: popupMouseArea.containsMouse

    width: Math.min(260, Screen.width - Theme.spacingM * 2)
    height: brightnessContent.height + Theme.spacingS * 2
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.spacingM
    color: Theme.popupBackground()
    radius: Theme.cornerRadius
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                          Theme.outline.b, 0.08)
    border.width: 1
    opacity: root.brightnessPopupVisible ? 1 : 0
    scale: root.brightnessPopupVisible ? 1 : 0.9
    layer.enabled: true

    Column {
      id: brightnessContent

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
            name: {
              const deviceInfo = BrightnessService.getCurrentDeviceInfo();
              
              if (!deviceInfo || deviceInfo.class === "backlight") {
                // Display backlight
                return "brightness_medium";
              } else if (deviceInfo.name.includes("kbd")) {
                // Keyboard brightness
                return "keyboard";
              } else {
                // Other devices (LEDs, etc.)
                return "lightbulb";
              }
            }
            size: Theme.iconSize
            color: Theme.primary
          }
        }

        DankSlider {
          id: brightnessSlider

          width: parent.width - Theme.iconSize - parent.gap * 3
          height: 40
          x: parent.gap * 2 + Theme.iconSize
          anchors.verticalCenter: parent.verticalCenter
          minimum: 1
          maximum: 100
          enabled: BrightnessService.brightnessAvailable
          showValue: true
          unit: "%"
          Component.onCompleted: {
            if (BrightnessService.brightnessAvailable)
              value = BrightnessService.brightnessLevel
          }
          onSliderValueChanged: function (newValue) {
            if (BrightnessService.brightnessAvailable) {
              brightnessDebounceTimer.pendingValue = newValue
              brightnessDebounceTimer.restart()
              root.resetHideTimer()
            }
          }
          onSliderDragFinished: function (finalValue) {
            if (BrightnessService.brightnessAvailable) {
              brightnessDebounceTimer.stop()
              BrightnessService.setBrightnessInternal(finalValue, BrightnessService.lastIpcDevice)
            }
          }

          Connections {
            function onBrightnessChanged() {
              brightnessSlider.value = BrightnessService.brightnessLevel
            }
            
            function onDeviceSwitched() {
              brightnessSlider.value = BrightnessService.brightnessLevel
            }

            target: BrightnessService
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
      y: root.brightnessPopupVisible ? 0 : 20
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
    item: brightnessPopup
  }
}
