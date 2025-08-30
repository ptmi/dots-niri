import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.SettingsPanel
import qs.Services
import qs.Widgets

Item {
  id: root

  property ShellScreen screen
  property real scaling: ScalingService.scale(screen)

  implicitWidth: pill.width
  implicitHeight: pill.height
  visible: true

  function getIcon() {
    if (!NightLightService.enabled) {
      return "light_mode"
    }
    return NightLightService.isActive ? "dark_mode" : "light_mode"
  }

  function getTooltipText() {
    if (!NightLightService.enabled) {
      return "Night Light: Disabled\nLeft click to open settings.\nRight click to enable."
    }

    var status = NightLightService.isActive ? "Active" : "Inactive (outside schedule)"
    var warmth = Math.round(NightLightService.warmth * 10)
    var schedule = NightLightService.autoSchedule ? `Schedule: ${NightLightService.startTime} - ${NightLightService.stopTime}` : "Manual mode"

    return `Night Light: ${status}\nWarmth: ${warmth}/10\n${schedule}\nLeft click to open settings.\nRight click to toggle.`
  }

  NPill {
    id: pill
    icon: getIcon()
    iconCircleColor: NightLightService.isActive ? Color.mSecondary : Color.mOnSurfaceVariant
    collapsedIconColor: NightLightService.isActive ? Color.mOnSecondary : Color.mOnSurface
    autoHide: false
    text: NightLightService.enabled ? (NightLightService.isActive ? "ON" : "OFF") : "OFF"
    tooltipText: getTooltipText()

    onClicked: {
      // Left click - open settings
      var settingsPanel = PanelService.getPanel("settingsPanel")
      settingsPanel.requestedTab = SettingsPanel.Tab.Display
      settingsPanel.open(screen)
    }

    onRightClicked: {
      // Right click - toggle night light
      NightLightService.toggle()
    }
  }

  // Update when service state changes
  Connections {
    target: NightLightService
    function onEnabledChanged() {
      pill.icon = getIcon()
      pill.text = NightLightService.enabled ? (NightLightService.isActive ? "ON" : "OFF") : "OFF"
      pill.tooltipText = getTooltipText()
    }
    function onIsActiveChanged() {
      pill.icon = getIcon()
      pill.text = NightLightService.enabled ? (NightLightService.isActive ? "ON" : "OFF") : "OFF"
      pill.tooltipText = getTooltipText()
    }
    function onWarmthChanged() {
      pill.tooltipText = getTooltipText()
    }
    function onStartTimeChanged() {
      pill.tooltipText = getTooltipText()
    }
    function onStopTimeChanged() {
      pill.tooltipText = getTooltipText()
    }
    function onAutoScheduleChanged() {
      pill.tooltipText = getTooltipText()
    }
  }
}
