pragma Singleton
pragma ComponentBehavior: Bound

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
            clearFocusedWindow();
            return;
        }

        let focusedWindow = NiriService.windows.find(w => w.is_focused);

        if (focusedWindow) {
            root.focusedAppId = focusedWindow.app_id || "";
            root.focusedWindowTitle = focusedWindow.title || "";
            root.focusedAppName = getDisplayName(focusedWindow.app_id || "");
            root.focusedWindowId = parseInt(focusedWindow.id) || -1;
        } else {
            clearFocusedWindow();
        }
    }


    function clearFocusedWindow() {
        root.focusedAppId = "";
        root.focusedAppName = "";
        root.focusedWindowTitle = "";
    }

    // Convert app_id to a more user-friendly display name
    function getDisplayName(appId) {
        if (!appId)
            return "";

        const appNames = {
            "com.mitchellh.ghostty": "Ghostty",
            "org.mozilla.firefox": "Firefox",
            "org.gnome.Nautilus": "Files",
            "org.gnome.TextEditor": "Text Editor",
            "com.google.Chrome": "Chrome",
            "org.telegram.desktop": "Telegram",
            "com.spotify.Client": "Spotify",
            "org.kde.konsole": "Konsole",
            "org.gnome.Terminal": "Terminal",
            "code": "VS Code",
            "code-oss": "VS Code",
            "org.mozilla.Thunderbird": "Thunderbird",
            "org.libreoffice.LibreOffice": "LibreOffice",
            "org.gimp.GIMP": "GIMP",
            "org.blender.Blender": "Blender",
            "discord": "Discord",
            "slack": "Slack",
            "zoom": "Zoom"
        };
        if (appNames[appId])
            return appNames[appId];

        
        let cleanName = appId.replace(/^(org\.|com\.|net\.|io\.)/, '').replace(/\./g, ' ').split(' ').map((word) => {
            return word.charAt(0).toUpperCase() + word.slice(1);
        }).join(' ');
        return cleanName;
    }

    Component.onCompleted: {
        root.niriAvailable = NiriService.niriAvailable;
        NiriService.onNiriAvailableChanged.connect(() => {
            root.niriAvailable = NiriService.niriAvailable;
            if (root.niriAvailable)
                updateFromNiriData();

        });
        if (root.niriAvailable)
            updateFromNiriData();

    }

    Connections {
        function onFocusedWindowIdChanged() {
            const focusedWindowId = NiriService.focusedWindowId;
            if (!focusedWindowId) {
                clearFocusedWindow();
                return;
            }
            
            const focusedWindow = NiriService.windows.find(w => w.id == focusedWindowId);
            if (focusedWindow) {
                root.focusedAppId = focusedWindow.app_id || "";
                root.focusedWindowTitle = focusedWindow.title || "";
                root.focusedAppName = getDisplayName(focusedWindow.app_id || "");
                root.focusedWindowId = parseInt(focusedWindow.id) || -1;
            } else {
                clearFocusedWindow();
            }
        }

        function onWindowsChanged() {
            updateFromNiriData();
        }

        function onWindowOpenedOrChanged(windowData) {
            if (windowData.is_focused) {
                root.focusedAppId = windowData.app_id || "";
                root.focusedWindowTitle = windowData.title || "";
                root.focusedAppName = getDisplayName(windowData.app_id || "");
                root.focusedWindowId = parseInt(windowData.id) || -1;
            }
        }

        target: NiriService
    }



}
