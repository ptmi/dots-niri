pragma ComponentBehavior

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Modules.Settings
import qs.Widgets

DankModal {
  id: settingsModal

  signal closingModal

  function show() {
    settingsModal.visible = true
  }

  function hide() {
    settingsModal.visible = false
  }

  function toggle() {
    if (settingsModal.visible)
      hide()
    else
      show()
  }

  width: 750
  height: 750
  visible: false
  keyboardFocus: "ondemand"
  onBackgroundClicked: hide()

  property Component settingsContent: Component {
    Item {
      anchors.fill: parent
      focus: true
      Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
          settingsModal.hide()
          event.accepted = true
        }
      }

      Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        Row {
          width: parent.width
          spacing: Theme.spacingM

          DankIcon {
            name: "settings"
            size: Theme.iconSize
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
          }

          StyledText {
            text: "Settings"
            font.pixelSize: Theme.fontSizeXLarge
            color: Theme.surfaceText
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
          }

          Item {
            width: parent.width - 175 // Spacer to push close button to the right
            height: 1
          }

          DankActionButton {
            circular: false
            iconName: "close"
            iconSize: Theme.iconSize - 4
            iconColor: Theme.surfaceText
            hoverColor: Theme.errorHover
            onClicked: settingsModal.hide()
          }
        }

        Column {
          width: parent.width
          height: parent.height - 50
          spacing: 0

          DankTabBar {
            id: settingsTabBar

            width: parent.width

            model: [{
                "text": "Personalization",
                "icon": "person"
              }, {
                "text": "Time & Weather",
                "icon": "schedule"
              }, {
                "text": "Widgets",
                "icon": "widgets"
              }, {
                "text": "Launcher",
                "icon": "apps"
              }, {
                "text": "Appearance",
                "icon": "palette"
              }]
          }

          Item {
            width: parent.width
            height: parent.height - settingsTabBar.height

            Rectangle {
              anchors.fill: parent
              anchors.margins: Theme.spacingL
              color: "transparent"

              Loader {
                id: personalizationLoader
                anchors.fill: parent
                active: settingsTabBar.currentIndex === 0
                visible: active
                asynchronous: true
                sourceComponent: Component {
                  PersonalizationTab {}
                }
              }

              Loader {
                id: timeWeatherLoader
                anchors.fill: parent
                active: settingsTabBar.currentIndex === 1
                visible: active
                asynchronous: true
                sourceComponent: Component {
                  TimeWeatherTab {}
                }
              }

              Loader {
                id: widgetsLoader
                anchors.fill: parent
                active: settingsTabBar.currentIndex === 2
                visible: active
                asynchronous: true
                sourceComponent: Component {
                  WidgetsTab {}
                }
              }

              Loader {
                id: launcherLoader
                anchors.fill: parent
                active: settingsTabBar.currentIndex === 3
                visible: active
                asynchronous: true
                sourceComponent: Component {
                  LauncherTab {}
                }
              }

              Loader {
                id: appearanceLoader
                anchors.fill: parent
                active: settingsTabBar.currentIndex === 4
                visible: active
                asynchronous: true
                sourceComponent: Component {
                  AppearanceTab {}
                }
              }
            }
          }
        }
      }
    }
  }

  content: settingsContent

  IpcHandler {
    function open() {
      settingsModal.show()
      return "SETTINGS_OPEN_SUCCESS"
    }

    function close() {
      settingsModal.hide()
      return "SETTINGS_CLOSE_SUCCESS"
    }

    function toggle() {
      settingsModal.toggle()
      return "SETTINGS_TOGGLE_SUCCESS"
    }

    target: "settings"
  }
}
