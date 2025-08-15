pragma Singleton

pragma ComponentBehavior

import QtQuick
import Quickshell

Singleton {
  id: root

  readonly property int levelInfo: 0
  readonly property int levelWarn: 1
  readonly property int levelError: 2
  property string currentMessage: ""
  property int currentLevel: levelInfo
  property bool toastVisible: false
  property var toastQueue: []
  property string wallpaperErrorStatus: ""

  function showToast(message, level = levelInfo) {
    toastQueue.push({
                      "message": message,
                      "level": level
                    })
    if (!toastVisible)
      processQueue()
  }

  function showInfo(message) {
    showToast(message, levelInfo)
  }

  function showWarning(message) {
    showToast(message, levelWarn)
  }

  function showError(message) {
    showToast(message, levelError)
  }

  function hideToast() {
    toastVisible = false
    currentMessage = ""
    currentLevel = levelInfo
    toastTimer.stop()
    if (toastQueue.length > 0)
      processQueue()
  }

  function processQueue() {
    if (toastQueue.length === 0)
      return

    const toast = toastQueue.shift()
    currentMessage = toast.message
    currentLevel = toast.level
    toastVisible = true
    toastTimer.interval = toast.level
        === levelError ? 5000 : toast.level === levelWarn ? 4000 : 3000
    toastTimer.start()
  }

  function clearWallpaperError() {
    wallpaperErrorStatus = ""
  }

  Timer {
    id: toastTimer

    interval: 5000
    running: false
    repeat: false
    onTriggered: hideToast()
  }
}
