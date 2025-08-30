pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Singleton {
  id: root

  // Night Light properties - directly bound to settings
  property bool enabled: Settings.data.nightLight?.enabled || false
  property real warmth: (Settings.data.nightLight
                         && Settings.data.nightLight.warmth !== undefined) ? Settings.data.nightLight.warmth : 0.6
  property real intensity: (Settings.data.nightLight
                            && Settings.data.nightLight.intensity !== undefined) ? Settings.data.nightLight.intensity : 0.8
  property string startTime: Settings.data.nightLight?.startTime || "20:00"
  property string stopTime: Settings.data.nightLight?.stopTime || "07:00"
  property bool autoSchedule: Settings.data.nightLight?.autoSchedule !== false

  // Computed properties
  property color overlayColor: enabled ? calculateOverlayColor() : "transparent"
  property bool isActive: enabled && warmth > 0 && (autoSchedule ? isWithinSchedule() : true)

  Component.onCompleted: {
    Logger.log("NightLight", "Service started")
  }

  function toggle() {
    Settings.data.nightLight.enabled = !Settings.data.nightLight.enabled
    Logger.log("NightLight", "Toggled:", Settings.data.nightLight.enabled)
  }

  function setWarmth(value) {
    Settings.data.nightLight.warmth = Math.max(0.0, Math.min(1.0, value))
    Logger.log("NightLight", "Warmth set to:", Settings.data.nightLight.warmth)
  }

  function setIntensity(value) {
    Settings.data.nightLight.intensity = Math.max(0.0, Math.min(1.0, value))
    Logger.log("NightLight", "Intensity set to:", Settings.data.nightLight.intensity)
  }

  function setSchedule(start, stop) {
    Settings.data.nightLight.startTime = start
    Settings.data.nightLight.stopTime = stop
    Logger.log("NightLight", "Schedule set to:", Settings.data.nightLight.startTime, "-",
               Settings.data.nightLight.stopTime)
  }

  function setAutoSchedule(auto) {
    Settings.data.nightLight.autoSchedule = auto
    Logger.log("NightLight", "Auto schedule set to:", Settings.data.nightLight.autoSchedule, "enabled:", enabled,
               "isActive:", isActive, "withinSchedule:", isWithinSchedule())
  }

  function calculateOverlayColor() {
    if (!isActive)
      return "transparent"

    // More vibrant color formula - stronger effect at high warmth
    var red = 1.0
    var green = 0.85 - warmth * 0.4 // More green reduction for stronger effect
    var blue = 0.5 - warmth * 0.45 // More blue reduction for warmer feel
    var alpha = 0.1 + warmth * 0.25 // Higher alpha for more noticeable effect

    // Apply intensity
    red = red * intensity
    green = green * intensity
    blue = blue * intensity

    return Qt.rgba(red, green, blue, alpha)
  }

  function isWithinSchedule() {
    if (!autoSchedule)
      return true

    var now = new Date()
    var currentTime = now.getHours() * 60 + now.getMinutes()

    var startParts = startTime.split(":")
    var stopParts = stopTime.split(":")
    var startMinutes = parseInt(startParts[0]) * 60 + parseInt(startParts[1])
    var stopMinutes = parseInt(stopParts[0]) * 60 + parseInt(stopParts[1])

    // Handle overnight schedule (e.g., 20:00 to 07:00)
    if (stopMinutes < startMinutes) {
      return currentTime >= startMinutes || currentTime <= stopMinutes
    } else {
      return currentTime >= startMinutes && currentTime <= stopMinutes
    }
  }

  // Timer to check schedule changes
  Timer {
    interval: 60000 // Check every minute
    running: true
    repeat: true
    onTriggered: {
      if (autoSchedule && enabled) {
        // Force overlay update when schedule changes
        Logger.log("NightLight", "Schedule check - enabled:", enabled, "autoSchedule:", autoSchedule, "isActive:",
                   isActive, "withinSchedule:", isWithinSchedule())
      }
    }
  }
}
