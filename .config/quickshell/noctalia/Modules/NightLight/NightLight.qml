import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services

Variants {
  model: Quickshell.screens

  delegate: Loader {
    required property ShellScreen modelData
    readonly property real scaling: ScalingService.scale(modelData)

    active: NightLightService.enabled

    sourceComponent: PanelWindow {
      id: nightlightWindow

      screen: modelData
      visible: NightLightService.isActive
      color: Color.transparent

      mask: Region {}

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      WlrLayershell.layer: WlrLayershell.Overlay
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "noctalia-nightlight"

      Rectangle {
        anchors.fill: parent
        color: NightLightService.overlayColor
      }

      // Safe connection that checks if the window still exists
      Connections {
        target: NightLightService
        function onIsActiveChanged() {
          if (nightlightWindow && typeof nightlightWindow.visible !== 'undefined') {
            nightlightWindow.visible = NightLightService.isActive
          }
        }
      }

      // Cleanup when component is being destroyed
      Component.onDestruction: {
        Logger.log("NightLight", "PanelWindow being destroyed")
      }
    }

    // Safe state changes
    onActiveChanged: {
      if (!active) {
        Logger.log("NightLight", "Loader deactivating for screen:", modelData.name)
      }
    }
  }
}
