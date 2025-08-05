//@ pragma UseQApplication

import Quickshell
import qs.Modules
import qs.Modules.CentcomCenter
import qs.Modules.ControlCenter
import qs.Modules.Settings
import qs.Modules.TopBar
import qs.Modules.ProcessList
import qs.Modules.ControlCenter.Network
import qs.Common as Common
import QtQuick 6.0
import qs.Modules.TopBar





ShellRoot {
    id: root

    function runShellCmd(cmd) {
        Shell.run(cmd);
    }

    // Multi-monitor support using Variants
    Variants {
        model: Quickshell.screens

        delegate: TopBar {
            modelData: item
            runShellCmd: root.runShellCmd
            shell: Common.shell
        }

    }



    // Global popup windows
    CentcomCenter {
        id: centcomCenter
    }

    TrayMenuPopup {
        id: trayMenuPopup
    }

    NotificationCenter {
        id: notificationCenter
    }


    NotificationPopup {
        id: notificationPopup
    }

    ControlCenter {
        id: controlCenter
        onPowerActionRequested: (action, title, message) => {
            powerConfirmDialog.powerConfirmAction = action;
            powerConfirmDialog.powerConfirmTitle = title;
            powerConfirmDialog.powerConfirmMessage = message;
            powerConfirmDialog.powerConfirmVisible = true;
        }
    }

    WifiPasswordDialog {
        id: wifiPasswordDialog
    }

    NetworkInfoDialog {
        id: networkInfoDialog
    }

    BatteryControlPopup {
        id: batteryControlPopup
    }

    PowerMenuPopup {
        id: powerMenuPopup
    }

    PowerConfirmDialog {
        id: powerConfirmDialog
    }

    ProcessListDropdown {
        id: processListDropdown
    }

    SettingsModal {
        id: settingsModal
    }


    // Application and clipboard components
    AppLauncher {
        id: appLauncher
    }

    SpotlightLauncher {
        id: spotlightLauncher
    }

    ProcessListModal {
        id: processListModal
    }

    ClipboardHistoryModal {
        id: clipboardHistoryModalPopup
    }

    Toast {
        id: toastWidget
    }

}
