import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
  id: root

  property var contextMenu: null
  property var windowsMenu: null
  property bool requestDockShow: false
  property int pinnedAppCount: 0

  implicitWidth: row.width
  implicitHeight: row.height

  function movePinnedApp(fromIndex, toIndex) {
    if (fromIndex === toIndex)
      return

    var currentPinned = [...(SessionData.pinnedApps || [])]
    if (fromIndex < 0 || fromIndex >= currentPinned.length || toIndex < 0
        || toIndex >= currentPinned.length)
      return

    var movedApp = currentPinned.splice(fromIndex, 1)[0]
    currentPinned.splice(toIndex, 0, movedApp)

    SessionData.setPinnedApps(currentPinned)
  }

  Row {
    id: row
    spacing: 2
    anchors.centerIn: parent
    height: 40

    Repeater {
      id: repeater
      model: ListModel {
        id: dockModel

        Component.onCompleted: updateModel()

        function updateModel() {
          clear()

          var items = []
          var runningApps = NiriService.getRunningAppIds()
          var pinnedApps = [...(SessionData.pinnedApps || [])]
          var addedApps = new Set()

          pinnedApps.forEach(appId => {
                               var lowerAppId = appId.toLowerCase()
                               if (!addedApps.has(lowerAppId)) {
                                 var windows = NiriService.getWindowsByAppId(
                                   appId)
                                 items.push({
                                              "appId": appId,
                                              "windows": windows,
                                              "isPinned": true,
                                              "isRunning": windows.length > 0
                                            })
                                 addedApps.add(lowerAppId)
                               }
                             })
          root.pinnedAppCount = pinnedApps.length
          var appUsageRanking = AppUsageHistoryData.appUsageRanking || {}

          var unpinnedApps = []
          var unpinnedAppsSet = new Set()

          // First: Add ALL currently running apps that aren't pinned
          runningApps.forEach(appId => {
                                var lowerAppId = appId.toLowerCase()
                                if (!addedApps.has(lowerAppId)) {
                                  unpinnedApps.push(appId)
                                  unpinnedAppsSet.add(lowerAppId)
                                }
                              })

          // Then: Fill remaining slots up to 3 with recently used apps
          var remainingSlots = Math.max(0, 3 - unpinnedApps.length)
          if (remainingSlots > 0) {
            // Sort recent apps by usage
            var recentApps = []
            for (var appId in appUsageRanking) {
              var lowerAppId = appId.toLowerCase()
              if (!addedApps.has(lowerAppId) && !unpinnedAppsSet.has(
                    lowerAppId)) {
                recentApps.push({
                                  "appId": appId,
                                  "lastUsed": appUsageRanking[appId].lastUsed
                                  || 0
                                })
              }
            }
            recentApps.sort((a, b) => b.lastUsed - a.lastUsed)

            var recentToAdd = Math.min(remainingSlots, recentApps.length)
            for (var i = 0; i < recentToAdd; i++) {
              unpinnedApps.push(recentApps[i].appId)
            }
          }
          if (pinnedApps.length > 0 && unpinnedApps.length > 0) {
            items.push({
                         "appId": "__SEPARATOR__",
                         "windows": [],
                         "isPinned": false,
                         "isRunning": false
                       })
          }
          unpinnedApps.forEach(appId => {
                                 var windows = NiriService.getWindowsByAppId(
                                   appId)
                                 items.push({
                                              "appId": appId,
                                              "windows": windows,
                                              "isPinned": false,
                                              "isRunning": windows.length > 0
                                            })
                               })
          items.forEach(item => {
                          append(item)
                        })
        }
      }

      delegate: Item {
        id: delegateItem
        property alias dockButton: button

        width: model.appId === "__SEPARATOR__" ? 16 : 40
        height: 40

        Rectangle {
          visible: model.appId === "__SEPARATOR__"
          width: 2
          height: 20
          color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
          radius: 1
          anchors.centerIn: parent
        }

        DockAppButton {
          id: button
          visible: model.appId !== "__SEPARATOR__"
          anchors.centerIn: parent

          width: 40
          height: 40

          appData: model
          contextMenu: root.contextMenu
          windowsMenu: root.windowsMenu
          dockApps: root
          index: model.index
        }
      }
    }
  }

  Connections {
    target: NiriService
    function onWindowsChanged() {
      dockModel.updateModel()
    }
    function onWindowOpenedOrChanged() {
      dockModel.updateModel()
    }
  }

  Connections {
    target: SessionData
    function onPinnedAppsChanged() {
      dockModel.updateModel()
    }
  }
}
