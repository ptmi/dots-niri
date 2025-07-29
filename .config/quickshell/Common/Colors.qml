pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {

    id: root

    readonly property string _homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    readonly property string homeDir: _homeUrl.startsWith("file://") ? _homeUrl.substring(7) : _homeUrl
    readonly property string wallpaperPath: homeDir + "/quickshell/current_wallpaper"
    readonly property string notifyPath: homeDir + "/quickshell/wallpaper_changed"
    property bool matugenAvailable: false
    property string matugenJson: ""
    property var matugenColors: ({
    })
    property bool extractionRequested: false
    property int colorUpdateTrigger: 0
    property string lastWallpaperTimestamp: ""
    property color primary: getMatugenColor("primary", "#42a5f5")
    property color secondary: getMatugenColor("secondary", "#8ab4f8")
    property color tertiary: getMatugenColor("tertiary", "#bb86fc")
    property color tertiaryContainer: getMatugenColor("tertiary_container", "#3700b3")
    property color error: getMatugenColor("error", "#cf6679")
    property color inversePrimary: getMatugenColor("inverse_primary", "#6200ea")
    property color bg: getMatugenColor("background", "#1a1c1e")
    property color surface: getMatugenColor("surface", "#1a1c1e")
    property color surfaceContainer: getMatugenColor("surface_container", "#1e2023")
    property color surfaceContainerHigh: getMatugenColor("surface_container_high", "#292b2f")
    property color surfaceVariant: getMatugenColor("surface_variant", "#44464f")
    property color surfaceText: getMatugenColor("on_background", "#e3e8ef")
    property color primaryText: getMatugenColor("on_primary", "#ffffff")
    property color surfaceVariantText: getMatugenColor("on_surface_variant", "#c4c7c5")
    property color primaryContainer: getMatugenColor("primary_container", "#1976d2")
    property color surfaceTint: getMatugenColor("surface_tint", "#8ab4f8")
    property color outline: getMatugenColor("outline", "#8e918f")
    property color accentHi: primary
    property color accentLo: secondary

    signal colorsUpdated()

    function onLightModeChanged() {
        if (matugenColors && Object.keys(matugenColors).length > 0) {
            console.log("Light mode changed - updating dynamic colors");
            colorUpdateTrigger++;
            colorsUpdated();
        }
    }

    function extractColors() {
        console.log("Colors.extractColors() called, matugenAvailable:", matugenAvailable);
        extractionRequested = true;
        if (matugenAvailable)
            fileChecker.running = true;
        else
            matugenCheck.running = true;
    }

    function getMatugenColor(path, fallback) {
        colorUpdateTrigger;
        const colorMode = (typeof Theme !== "undefined" && Theme.isLightMode) ? "light" : "dark";
        let cur = matugenColors && matugenColors.colors && matugenColors.colors[colorMode];
        for (const part of path.split(".")) {
            if (!cur || typeof cur !== "object" || !(part in cur))
                return fallback;

            cur = cur[part];
        }
        return cur || fallback;
    }

    function isColorDark(c) {
        return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) < 0.5;
    }

    Component.onCompleted: {
        console.log("Colors.qml → home =", homeDir);
        matugenCheck.running = true;
        if (typeof Theme !== "undefined")
            Theme.isLightModeChanged.connect(root.onLightModeChanged);
    }

    Process {
        id: matugenCheck

        command: ["which", "matugen"]
        onExited: (code) => {
            matugenAvailable = (code === 0);
            console.log("Matugen in PATH:", matugenAvailable);
            if (!matugenAvailable) {
                console.warn("Matugen missing → dynamic theme disabled");
                ToastService.wallpaperErrorStatus = "matugen_missing";
                ToastService.showWarning("matugen not found - dynamic theming disabled");
                return ;
            }
            if (extractionRequested) {
                console.log("Continuing with color extraction");
                fileChecker.running = true;
            }
        }
    }

    Process {
        id: fileChecker

        command: ["test", "-r", wallpaperPath]
        onExited: (code) => {
            if (code === 0) {
                matugenProcess.running = true;
            } else {
                console.error("code", code);
                console.error("Wallpaper not found:", wallpaperPath);
                ToastService.wallpaperErrorStatus = "error";
                ToastService.showError("Wallpaper processing failed");
            }
        }
    }

    Process {
        id: matugenProcess

        command: ["matugen", "-v", "image", wallpaperPath, "--json", "hex"]

        stdout: StdioCollector {
            id: matugenCollector

            onStreamFinished: {
                const out = matugenCollector.text;
                if (!out.length) {
                    console.error("matugen produced zero bytes\nstderr:", matugenProcess.stderr);
                    ToastService.wallpaperErrorStatus = "error";
                    ToastService.showError("Wallpaper Processing Failed");
                    return ;
                }
                try {
                    root.matugenJson = out;
                    root.matugenColors = JSON.parse(out);
                    root.colorsUpdated();
                    ToastService.clearWallpaperError();
                } catch (e) {
                    console.error("JSON parse failed:", e);
                    ToastService.wallpaperErrorStatus = "error";
                    ToastService.showError("Wallpaper Processing Failed");
                }
            }
        }

        stderr: StdioCollector {
            id: matugenErr
        }

    }

}
