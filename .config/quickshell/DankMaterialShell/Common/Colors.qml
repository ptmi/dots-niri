pragma Singleton

pragma ComponentBehavior

import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
  id: root

  readonly property string _homeUrl: StandardPaths.writableLocation(
                                       StandardPaths.HomeLocation)
  readonly property string homeDir: _homeUrl.startsWith(
                                      "file://") ? _homeUrl.substring(
                                                     7) : _homeUrl
  readonly property string _configUrl: StandardPaths.writableLocation(
                                         StandardPaths.ConfigLocation)
  readonly property string configDir: _configUrl.startsWith(
                                        "file://") ? _configUrl.substring(
                                                       7) : _configUrl
  readonly property string shellDir: Qt.resolvedUrl(".").toString().replace(
                                       "file://", "").replace("/Common/", "")
  readonly property string wallpaperPath: SessionData.wallpaperPath
  property bool matugenAvailable: false
  property bool gtkThemingEnabled: false
  property bool qtThemingEnabled: false
  property bool systemThemeGenerationInProgress: false
  property var matugenColors: ({})
  property bool extractionRequested: false
  property int colorUpdateTrigger: 0
  property string lastWallpaperTimestamp: ""
  property color primary: getMatugenColor("primary", "#42a5f5")
  property color secondary: getMatugenColor("secondary", "#8ab4f8")
  property color tertiary: getMatugenColor("tertiary", "#bb86fc")
  property color tertiaryContainer: getMatugenColor("tertiary_container",
                                                    "#3700b3")
  property color error: getMatugenColor("error", "#cf6679")
  property color inversePrimary: getMatugenColor("inverse_primary", "#6200ea")
  property color bg: getMatugenColor("background", "#1a1c1e")
  property color surface: getMatugenColor("surface", "#1a1c1e")
  property color surfaceContainer: getMatugenColor("surface_container",
                                                   "#1e2023")
  property color surfaceContainerHigh: getMatugenColor(
                                         "surface_container_high", "#292b2f")
  property color surfaceVariant: getMatugenColor("surface_variant", "#44464f")
  property color surfaceText: getMatugenColor("on_background", "#e3e8ef")
  property color primaryText: getMatugenColor("on_primary", "#ffffff")
  property color surfaceVariantText: getMatugenColor("on_surface_variant",
                                                     "#c4c7c5")
  property color primaryContainer: getMatugenColor("primary_container",
                                                   "#1976d2")
  property color surfaceTint: getMatugenColor("surface_tint", "#8ab4f8")
  property color outline: getMatugenColor("outline", "#8e918f")
  property color accentHi: primary
  property color accentLo: secondary

  signal colorsUpdated

  function onLightModeChanged() {
    if (matugenColors && Object.keys(matugenColors).length > 0) {
      colorUpdateTrigger++
      colorsUpdated()

      if (typeof Theme !== "undefined" && Theme.isDynamicTheme) {
        generateSystemThemes()
      }
    }
  }

  function extractColors() {
    extractionRequested = true
    if (matugenAvailable)
      fileChecker.running = true
    else
      matugenCheck.running = true
  }

  function getMatugenColor(path, fallback) {
    colorUpdateTrigger
    const colorMode = (typeof SessionData !== "undefined"
                       && SessionData.isLightMode) ? "light" : "dark"
    let cur = matugenColors && matugenColors.colors
        && matugenColors.colors[colorMode]
    for (const part of path.split(".")) {
      if (!cur || typeof cur !== "object" || !(part in cur))
        return fallback

      cur = cur[part]
    }
    return cur || fallback
  }

  function isColorDark(c) {
    return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) < 0.5
  }

  Component.onCompleted: {
    matugenCheck.running = true
    checkGtkThemingAvailability()
    checkQtThemingAvailability()
    if (typeof SessionData !== "undefined")
    SessionData.isLightModeChanged.connect(root.onLightModeChanged)
  }

  Process {
    id: matugenCheck

    command: ["which", "matugen"]
    onExited: code => {
      matugenAvailable = (code === 0)
      if (!matugenAvailable) {
        ToastService.wallpaperErrorStatus = "matugen_missing"
        ToastService.showWarning("matugen not found - dynamic theming disabled")
        return
      }
      if (extractionRequested) {
        fileChecker.running = true
      }
    }
  }

  Process {
    id: fileChecker

    command: ["test", "-r", wallpaperPath]
    onExited: code => {
      if (code === 0) {
        matugenProcess.running = true
      } else {
        ToastService.wallpaperErrorStatus = "error"
        ToastService.showError("Wallpaper processing failed")
      }
    }
  }

  Process {
    id: matugenProcess

    command: ["matugen", "image", wallpaperPath, "--json", "hex"]

    stdout: StdioCollector {
      id: matugenCollector

      onStreamFinished: {
        if (!matugenCollector.text) {
          ToastService.wallpaperErrorStatus = "error"
          ToastService.showError("Wallpaper Processing Failed: Empty JSON extracted from matugen output.")
          return
        }
        try {
          root.matugenColors = JSON.parse(matugenCollector.text)
          root.colorsUpdated()
          generateAppConfigs()
          ToastService.clearWallpaperError()
        } catch (e) {
          ToastService.wallpaperErrorStatus = "error"
          ToastService.showError("Wallpaper processing failed (JSON parse error after extraction)")
        }
      }
    }

    onExited: code => {
      if (code !== 0) {
        ToastService.wallpaperErrorStatus = "error"
        ToastService.showError("Matugen command failed with exit code " + code)
      }
    }
  }

  function generateAppConfigs() {
    if (!matugenColors || !matugenColors.colors) {
      return
    }

    generateNiriConfig()
    generateGhosttyConfig()

    if (gtkThemingEnabled && typeof SettingsData !== "undefined"
        && SettingsData.gtkThemingEnabled) {
      generateSystemThemes()
    } else if (qtThemingEnabled && typeof SettingsData !== "undefined"
               && SettingsData.qtThemingEnabled) {
      generateSystemThemes()
    }
  }

  function generateNiriConfig() {
    var dark = matugenColors.colors.dark
    if (!dark)
      return

    var bg = dark.background || "#1a1c1e"
    var primary = dark.primary || "#42a5f5"
    var secondary = dark.secondary || "#8ab4f8"
    var inverse = dark.inverse_primary || "#6200ea"

    var content = `layout {
    border {
    active-color   "${primary}"
    inactive-color "${secondary}"
    }
    focus-ring {
    active-color   "${inverse}"
    }
    background-color "${bg}"
    }`

    Quickshell.execDetached(
          ["bash", "-c", `echo '${content}' > niri-colors.generated.kdl`])
  }

  function generateGhosttyConfig() {
    var dark = matugenColors.colors.dark
    var light = matugenColors.colors.light
    if (!dark || !light)
      return

    var bg = dark.background || "#1a1c1e"
    var fg = dark.on_background || "#e3e8ef"
    var primary = dark.primary || "#42a5f5"
    var secondary = dark.secondary || "#8ab4f8"
    var tertiary = dark.tertiary || "#bb86fc"
    var tertiary_ctr = dark.tertiary_container || "#3700b3"
    var error = dark.error || "#cf6679"
    var inverse = dark.inverse_primary || "#6200ea"

    var bg_b = light.background || "#fef7ff"
    var fg_b = light.on_background || "#1d1b20"
    var primary_b = light.primary || "#1976d2"
    var secondary_b = light.secondary || "#1565c0"
    var tertiary_b = light.tertiary || "#7b1fa2"
    var tertiary_ctr_b = light.tertiary_container || "#e1bee7"
    var error_b = light.error || "#b00020"
    var inverse_b = light.inverse_primary || "#bb86fc"

    var content = `background = ${bg}
    foreground = ${fg}
    cursor-color = ${inverse}
    selection-background = ${secondary}
    selection-foreground = #ffffff
    palette = 0=${bg}
    palette = 1=${error}
    palette = 2=${tertiary}
    palette = 3=${secondary}
    palette = 4=${primary}
    palette = 5=${tertiary_ctr}
    palette = 6=${inverse}
    palette = 7=${fg}
    palette = 8=${bg_b}
    palette = 9=${error_b}
    palette = 10=${tertiary_b}
    palette = 11=${secondary_b}
    palette = 12=${primary_b}
    palette = 13=${tertiary_ctr_b}
    palette = 14=${inverse_b}
    palette = 15=${fg_b}`

    var ghosttyConfigDir = configDir + "/ghostty"
    var ghosttyConfigPath = ghosttyConfigDir + "/config-dankcolors"

    Quickshell.execDetached(
          ["bash", "-c", `mkdir -p '${ghosttyConfigDir}' && echo '${content}' > '${ghosttyConfigPath}'`])
  }

  function checkGtkThemingAvailability() {
    gtkAvailabilityChecker.running = true
  }

  function checkQtThemingAvailability() {
    qtAvailabilityChecker.running = true
  }

  function generateSystemThemes() {
    if (systemThemeGenerationInProgress) {
      return
    }

    if (!matugenAvailable) {
      return
    }

    if (!wallpaperPath || wallpaperPath === "") {
      return
    }

    const isLight = (typeof SessionData !== "undefined"
                     && SessionData.isLightMode) ? "true" : "false"
    const iconTheme = (typeof SettingsData !== "undefined"
                       && SettingsData.iconTheme) ? SettingsData.iconTheme : "System Default"
    const gtkTheming = (typeof SettingsData !== "undefined"
                        && SettingsData.gtkThemingEnabled) ? "true" : "false"
    const qtTheming = (typeof SettingsData !== "undefined"
                       && SettingsData.qtThemingEnabled) ? "true" : "false"

    systemThemeGenerationInProgress = true
    systemThemeGenerator.command = [shellDir + "/generate-themes.sh", wallpaperPath, shellDir, configDir, "generate", isLight, iconTheme, gtkTheming, qtTheming]
    systemThemeGenerator.running = true
  }

  function restoreSystemThemes() {
    const shellDir = root.shellDir
    if (!shellDir) {
      return
    }

    const isLight = (typeof SessionData !== "undefined"
                     && SessionData.isLightMode) ? "true" : "false"
    const iconTheme = (typeof SettingsData !== "undefined"
                       && SettingsData.iconTheme) ? SettingsData.iconTheme : "System Default"
    const gtkTheming = (typeof SettingsData !== "undefined"
                        && SettingsData.gtkThemingEnabled) ? "true" : "false"
    const qtTheming = (typeof SettingsData !== "undefined"
                       && SettingsData.qtThemingEnabled) ? "true" : "false"

    systemThemeRestoreProcess.command = [shellDir + "/generate-themes.sh", "", shellDir, configDir, "restore", isLight, iconTheme, gtkTheming, qtTheming]
    systemThemeRestoreProcess.running = true
  }

  Process {
    id: gtkAvailabilityChecker
    command: ["bash", "-c", "command -v gsettings >/dev/null && [ -d "
      + configDir + "/gtk-3.0 -o -d " + configDir + "/gtk-4.0 ]"]
    running: false
    onExited: exitCode => {
      gtkThemingEnabled = (exitCode === 0)
    }
  }

  Process {
    id: qtAvailabilityChecker
    command: ["bash", "-c", "command -v qt5ct >/dev/null || command -v qt6ct >/dev/null"]
    running: false
    onExited: exitCode => {
      qtThemingEnabled = (exitCode === 0)
    }
  }

  Process {
    id: systemThemeGenerator
    running: false

    stdout: StdioCollector {
      id: systemThemeStdout
    }

    stderr: StdioCollector {
      id: systemThemeStderr
    }

    onExited: exitCode => {
      systemThemeGenerationInProgress = false

      if (exitCode !== 0) {
        ToastService.showError(
          "Failed to generate system themes: " + systemThemeStderr.text)
      }
    }
  }

  Process {
    id: systemThemeRestoreProcess
    running: false

    stdout: StdioCollector {
      id: restoreThemeStdout
    }

    stderr: StdioCollector {
      id: restoreThemeStderr
    }

    onExited: exitCode => {
      if (exitCode === 0) {
        ToastService.showInfo("System themes restored to default")
      } else {
        ToastService.showWarning(
          "Failed to restore system themes: " + restoreThemeStderr.text)
      }
    }
  }
}
