pragma Singleton

pragma ComponentBehavior

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property bool niriAvailable: false
  property string focusedAppId: ""
  property string focusedAppName: ""
  property string focusedWindowTitle: ""
  property int focusedWindowId: -1

  function updateFromNiriData() {
    if (!root.niriAvailable) {
      clearFocusedWindow()
      return
    }

    let focusedWindow = NiriService.windows.find(w => w.is_focused)

    if (focusedWindow) {
      root.focusedAppId = focusedWindow.app_id || ""
      root.focusedWindowTitle = focusedWindow.title || ""
      root.focusedAppName = getDisplayName(focusedWindow.app_id || "")
      root.focusedWindowId = parseInt(focusedWindow.id) || -1
    } else {
      clearFocusedWindow()
    }
  }

  function clearFocusedWindow() {
    root.focusedAppId = ""
    root.focusedAppName = ""
    root.focusedWindowTitle = ""
  }

  // Convert app_id to a more user-friendly display name
  function getDisplayName(appId) {
    if (!appId)
      return ""
    const desktopEntry = DesktopEntries.byId(appId)
    return desktopEntry && desktopEntry.name ? desktopEntry.name : ""
  }

  Component.onCompleted: {
    root.niriAvailable = NiriService.niriAvailable
    NiriService.onNiriAvailableChanged.connect(() => {
                                                 root.niriAvailable = NiriService.niriAvailable
                                                 if (root.niriAvailable)
                                                 updateFromNiriData()
                                               })
    if (root.niriAvailable)
    updateFromNiriData()
  }

  Connections {
    function onFocusedWindowIdChanged() {
      const focusedWindowId = NiriService.focusedWindowId
      if (!focusedWindowId) {
        clearFocusedWindow()
        return
      }

      const focusedWindow = NiriService.windows.find(
                            w => w.id == focusedWindowId)
      if (focusedWindow) {
        root.focusedAppId = focusedWindow.app_id || ""
        root.focusedWindowTitle = focusedWindow.title || ""
        root.focusedAppName = getDisplayName(focusedWindow.app_id || "")
        root.focusedWindowId = parseInt(focusedWindow.id) || -1
      } else {
        clearFocusedWindow()
      }
    }

    function onWindowsChanged() {
      updateFromNiriData()
    }

    function onWindowOpenedOrChanged(windowData) {
      if (windowData.is_focused) {
        root.focusedAppId = windowData.app_id || ""
        root.focusedWindowTitle = windowData.title || ""
        root.focusedAppName = getDisplayName(windowData.app_id || "")
        root.focusedWindowId = parseInt(windowData.id) || -1
      }
    }

    target: NiriService
  }
}
