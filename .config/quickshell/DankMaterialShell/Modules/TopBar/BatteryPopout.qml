import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
  id: root

  property bool batteryPopupVisible: false
  property real triggerX: Screen.width - 380 - Theme.spacingL
  property real triggerY: Theme.barHeight + Theme.spacingS
  property real triggerWidth: 70
  property string triggerSection: "right"
  property var triggerScreen: null

  function setTriggerPosition(x, y, width, section, screen) {
    triggerX = x
    triggerY = y
    triggerWidth = width
    triggerSection = section
    triggerScreen = screen
  }

  function isActiveProfile(profile) {
    if (typeof PowerProfiles === "undefined")
      return false

    return PowerProfiles.profile === profile
  }

  function setProfile(profile) {
    if (typeof PowerProfiles === "undefined") {
      ToastService.showError("power-profiles-daemon not available")
      return
    }
    PowerProfiles.profile = profile
    if (PowerProfiles.profile !== profile)
      ToastService.showError("Failed to set power profile")
  }

  visible: batteryPopupVisible
  screen: triggerScreen
  implicitWidth: 400
  implicitHeight: 300
  WlrLayershell.layer: WlrLayershell.Overlay
  WlrLayershell.exclusiveZone: -1
  WlrLayershell.keyboardFocus: batteryPopupVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "transparent"

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
        batteryPopupVisible = false
    }
  }

  Loader {
    id: contentLoader

    readonly property real screenWidth: root.screen ? root.screen.width : Screen.width
    readonly property real screenHeight: root.screen ? root.screen.height : Screen.height
    readonly property real targetWidth: Math.min(
                                          380, screenWidth - Theme.spacingL * 2)
    readonly property real calculatedX: {
      var centerX = root.triggerX + (root.triggerWidth / 2) - (targetWidth / 2)

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
    active: batteryPopupVisible
    width: targetWidth
    height: item ? item.implicitHeight : 0
    x: calculatedX
    y: root.triggerY
    opacity: batteryPopupVisible ? 1 : 0
    scale: batteryPopupVisible ? 1 : 0.9

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
      implicitHeight: contentColumn.height + Theme.spacingL * 2
      color: Theme.popupBackground()
      radius: Theme.cornerRadius
      border.color: Theme.outlineMedium
      border.width: 1
      antialiasing: true
      smooth: true
      focus: true
      Component.onCompleted: {
        if (batteryPopupVisible)
          forceActiveFocus()
      }
      Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
          batteryPopupVisible = false
          event.accepted = true
        }
      }

      Connections {
        function onBatteryPopupVisibleChanged() {
          if (batteryPopupVisible)
            Qt.callLater(function () {
              parent.forceActiveFocus()
            })
        }
        target: root
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        color: "transparent"
        radius: parent.radius + 3
        border.color: Qt.rgba(0, 0, 0, 0.05)
        border.width: 1
        z: -3
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        color: "transparent"
        radius: parent.radius + 2
        border.color: Theme.shadowMedium
        border.width: 1
        z: -2
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.outlineStrong
        border.width: 1
        radius: parent.radius
        z: -1
      }

      Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingL

          Item {
            width: parent.width
            height: 32

            StyledText {
              text: BatteryService.batteryAvailable ? "Battery Information" : "Power Management"
              font.pixelSize: Theme.fontSizeLarge
              color: Theme.surfaceText
              font.weight: Font.Medium
              anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
              width: 32
              height: 32
              radius: 16
              color: closeBatteryArea.containsMouse ? Theme.errorHover : "transparent"
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter

              DankIcon {
                anchors.centerIn: parent
                name: "close"
                size: Theme.iconSize - 4
                color: closeBatteryArea.containsMouse ? Theme.error : Theme.surfaceText
              }

              MouseArea {
                id: closeBatteryArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  batteryPopupVisible = false
                }
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 80
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                           Theme.surfaceVariant.b,
                           Theme.getContentBackgroundAlpha() * 0.4)
            border.color: BatteryService.isCharging ? Theme.primary : (BatteryService.isLowBattery ? Theme.error : Theme.outlineMedium)
            border.width: BatteryService.isCharging
                          || BatteryService.isLowBattery ? 2 : 1
            visible: BatteryService.batteryAvailable

            Row {
              anchors.left: parent.left
              anchors.leftMargin: Theme.spacingL
              anchors.verticalCenter: parent.verticalCenter
              spacing: Theme.spacingL

              DankIcon {
                name: {
                  if (!BatteryService.batteryAvailable)
                    return "power"

                  // Check if plugged in but not charging (like at 80% charge limit)
                  if (!BatteryService.isCharging && BatteryService.isPluggedIn) {
                    if (BatteryService.batteryLevel >= 90)
                      return "battery_charging_full"
                    if (BatteryService.batteryLevel >= 80)
                      return "battery_charging_90"
                    if (BatteryService.batteryLevel >= 60)
                      return "battery_charging_80"
                    if (BatteryService.batteryLevel >= 50)
                      return "battery_charging_60"
                    if (BatteryService.batteryLevel >= 30)
                      return "battery_charging_50"
                    if (BatteryService.batteryLevel >= 20)
                      return "battery_charging_30"
                    return "battery_charging_20"
                  }

                  if (BatteryService.isCharging) {
                    if (BatteryService.batteryLevel >= 90)
                      return "battery_charging_full"
                    if (BatteryService.batteryLevel >= 80)
                      return "battery_charging_90"
                    if (BatteryService.batteryLevel >= 60)
                      return "battery_charging_80"
                    if (BatteryService.batteryLevel >= 50)
                      return "battery_charging_60"
                    if (BatteryService.batteryLevel >= 30)
                      return "battery_charging_50"
                    if (BatteryService.batteryLevel >= 20)
                      return "battery_charging_30"
                    return "battery_charging_20"
                  } else {
                    if (BatteryService.batteryLevel >= 95)
                      return "battery_full"
                    if (BatteryService.batteryLevel >= 85)
                      return "battery_6_bar"
                    if (BatteryService.batteryLevel >= 70)
                      return "battery_5_bar"
                    if (BatteryService.batteryLevel >= 55)
                      return "battery_4_bar"
                    if (BatteryService.batteryLevel >= 40)
                      return "battery_3_bar"
                    if (BatteryService.batteryLevel >= 25)
                      return "battery_2_bar"
                    return "battery_1_bar"
                  }
                }
                size: Theme.iconSizeLarge
                color: {
                  if (BatteryService.isLowBattery && !BatteryService.isCharging)
                    return Theme.error

                  if (BatteryService.isCharging || BatteryService.isPluggedIn)
                    return Theme.primary

                  return Theme.surfaceText
                }
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                Row {
                  spacing: Theme.spacingM

                  StyledText {
                    text: BatteryService.batteryLevel + "%"
                    font.pixelSize: Theme.fontSizeLarge
                    color: {
                      if (BatteryService.isLowBattery
                          && !BatteryService.isCharging)
                        return Theme.error

                      if (BatteryService.isCharging)
                        return Theme.primary

                      return Theme.surfaceText
                    }
                    font.weight: Font.Bold
                  }

                  StyledText {
                    text: BatteryService.batteryStatus
                    font.pixelSize: Theme.fontSizeMedium
                    color: {
                      if (BatteryService.isLowBattery
                          && !BatteryService.isCharging)
                        return Theme.error

                      if (BatteryService.isCharging)
                        return Theme.primary

                      return Theme.surfaceText
                    }
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }

                StyledText {
                  text: {
                    let time = BatteryService.formatTimeRemaining()
                    if (time !== "Unknown")
                      return BatteryService.isCharging ? "Time until full: "
                                                         + time : "Time remaining: " + time

                    return ""
                  }
                  font.pixelSize: Theme.fontSizeSmall
                  color: Theme.surfaceTextMedium
                  visible: text.length > 0
                }
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 80
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                           Theme.surfaceVariant.b,
                           Theme.getContentBackgroundAlpha() * 0.4)
            border.color: Theme.outlineMedium
            border.width: 1
            visible: !BatteryService.batteryAvailable

            Row {
              anchors.centerIn: parent
              spacing: Theme.spacingL

              DankIcon {
                name: "power"
                size: 36
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                spacing: Theme.spacingS
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                  text: "No Battery Detected"
                  font.pixelSize: Theme.fontSizeLarge
                  color: Theme.surfaceText
                  font.weight: Font.Medium
                }

                StyledText {
                  text: "Power profile management is available"
                  font.pixelSize: Theme.fontSizeMedium
                  color: Theme.surfaceTextMedium
                }
              }
            }
          }

          Column {
            width: parent.width
            spacing: Theme.spacingM
            visible: BatteryService.batteryAvailable

            StyledText {
              text: "Battery Details"
              font.pixelSize: Theme.fontSizeLarge
              color: Theme.surfaceText
              font.weight: Font.Medium
            }

            Row {
              width: parent.width
              spacing: Theme.spacingXL

              Column {
                spacing: 2
                width: (parent.width - Theme.spacingXL) / 2

                StyledText {
                  text: "Health"
                  font.pixelSize: Theme.fontSizeSmall
                  color: Theme.surfaceTextMedium
                  font.weight: Font.Medium
                }

                StyledText {
                  text: BatteryService.batteryHealth
                  font.pixelSize: Theme.fontSizeMedium
                  color: {
                    if (BatteryService.batteryHealth === "N/A")
                      return Theme.surfaceText

                    var healthNum = parseInt(BatteryService.batteryHealth)
                    return healthNum < 80 ? Theme.error : Theme.surfaceText
                  }
                }
              }

              Column {
                spacing: 2
                width: (parent.width - Theme.spacingXL) / 2

                StyledText {
                  text: "Capacity"
                  font.pixelSize: Theme.fontSizeSmall
                  color: Theme.surfaceTextMedium
                  font.weight: Font.Medium
                }

                StyledText {
                  text: BatteryService.batteryCapacity > 0 ? BatteryService.batteryCapacity.toFixed(
                                                               1) + " Wh" : "Unknown"
                  font.pixelSize: Theme.fontSizeMedium
                  color: Theme.surfaceText
                }
              }
            }
          }

          Column {
            width: parent.width
            spacing: Theme.spacingM
            visible: true

            StyledText {
              text: "Power Profile"
              font.pixelSize: Theme.fontSizeLarge
              color: Theme.surfaceText
              font.weight: Font.Medium
            }

            Column {
              width: parent.width
              spacing: Theme.spacingS

              Repeater {
                model: (typeof PowerProfiles
                        !== "undefined") ? [PowerProfile.PowerSaver, PowerProfile.Balanced].concat(
                                             PowerProfiles.hasPerformanceProfile ? [PowerProfile.Performance] : []) : [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

                Rectangle {
                  width: parent.width
                  height: 50
                  radius: Theme.cornerRadius
                  color: profileArea.containsMouse ? Theme.primaryHoverLight : (root.isActiveProfile(modelData) ? Theme.primaryPressed : Theme.surfaceLight)
                  border.color: root.isActiveProfile(
                                  modelData) ? Theme.primary : Theme.outlineLight
                  border.width: root.isActiveProfile(modelData) ? 2 : 1

                  Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingL
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingM

                    DankIcon {
                      name: Theme.getPowerProfileIcon(modelData)
                      size: Theme.iconSize
                      color: root.isActiveProfile(
                               modelData) ? Theme.primary : Theme.surfaceText
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                      spacing: 2
                      anchors.verticalCenter: parent.verticalCenter

                      StyledText {
                        text: Theme.getPowerProfileLabel(modelData)
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.isActiveProfile(
                                 modelData) ? Theme.primary : Theme.surfaceText
                        font.weight: root.isActiveProfile(
                                       modelData) ? Font.Medium : Font.Normal
                      }

                      StyledText {
                        text: Theme.getPowerProfileDescription(modelData)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                      }
                    }
                  }

                  MouseArea {
                    id: profileArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      root.setProfile(modelData)
                    }
                  }
                }
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 60
            radius: Theme.cornerRadius
            color: Theme.errorHover
            border.color: Theme.primarySelected
            border.width: 1
            visible: (typeof PowerProfiles !== "undefined")
                     && PowerProfiles.degradationReason !== PerformanceDegradationReason.None

            Row {
              anchors.left: parent.left
              anchors.leftMargin: Theme.spacingL
              anchors.verticalCenter: parent.verticalCenter
              spacing: Theme.spacingM

              DankIcon {
                name: "warning"
                size: Theme.iconSize
                color: Theme.error
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                  text: "Power Profile Degradation"
                  font.pixelSize: Theme.fontSizeMedium
                  color: Theme.error
                  font.weight: Font.Medium
                }

                StyledText {
                  text: (typeof PowerProfiles
                         !== "undefined") ? PerformanceDegradationReason.toString(
                                              PowerProfiles.degradationReason) : ""
                  font.pixelSize: Theme.fontSizeSmall
                  color: Qt.rgba(Theme.error.r, Theme.error.g,
                                 Theme.error.b, 0.8)
                }
              }
            }
          }
      }
    }
  }
}
