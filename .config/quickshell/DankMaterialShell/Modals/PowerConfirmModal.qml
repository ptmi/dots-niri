import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

DankModal {
  id: root

  property bool powerConfirmVisible: false
  property string powerConfirmAction: ""
  property string powerConfirmTitle: ""
  property string powerConfirmMessage: ""

  function executePowerAction(action) {
    switch (action) {
    case "logout":
      NiriService.quit()
      break
    case "suspend":
      Quickshell.execDetached(["systemctl", "suspend"])
      break
    case "reboot":
      Quickshell.execDetached(["systemctl", "reboot"])
      break
    case "poweroff":
      Quickshell.execDetached(["systemctl", "poweroff"])
      break
    }
  }

  visible: powerConfirmVisible
  width: 350
  height: 160
  keyboardFocus: "ondemand"
  enableShadow: false
  onBackgroundClicked: {
    powerConfirmVisible = false
  }

  content: Component {
    Item {
      anchors.fill: parent

      Column {
        anchors.centerIn: parent
        width: parent.width - Theme.spacingM * 2
        spacing: Theme.spacingM

        StyledText {
          text: powerConfirmTitle
          font.pixelSize: Theme.fontSizeLarge
          color: {
            switch (powerConfirmAction) {
            case "poweroff":
              return Theme.error
            case "reboot":
              return Theme.warning
            default:
              return Theme.surfaceText
            }
          }
          font.weight: Font.Medium
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
          text: powerConfirmMessage
          font.pixelSize: Theme.fontSizeMedium
          color: Theme.surfaceText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
        }

        Item {
          height: Theme.spacingS
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingM

          Rectangle {
            width: 120
            height: 40
            radius: Theme.cornerRadius
            color: cancelButton.containsMouse ? Theme.surfaceTextPressed : Theme.surfaceVariantAlpha

            StyledText {
              text: "Cancel"
              font.pixelSize: Theme.fontSizeMedium
              color: Theme.surfaceText
              font.weight: Font.Medium
              anchors.centerIn: parent
            }

            MouseArea {
              id: cancelButton

              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                powerConfirmVisible = false
              }
            }
          }

          Rectangle {
            width: 120
            height: 40
            radius: Theme.cornerRadius
            color: {
              let baseColor
              switch (powerConfirmAction) {
              case "poweroff":
                baseColor = Theme.error
                break
              case "reboot":
                baseColor = Theme.warning
                break
              default:
                baseColor = Theme.primary
                break
              }
              return confirmButton.containsMouse ? Qt.rgba(baseColor.r,
                                                           baseColor.g,
                                                           baseColor.b,
                                                           0.9) : baseColor
            }

            StyledText {
              text: "Confirm"
              font.pixelSize: Theme.fontSizeMedium
              color: Theme.primaryText
              font.weight: Font.Medium
              anchors.centerIn: parent
            }

            MouseArea {
              id: confirmButton

              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                powerConfirmVisible = false
                executePowerAction(powerConfirmAction)
              }
            }
          }
        }
      }
    }
  }
}
