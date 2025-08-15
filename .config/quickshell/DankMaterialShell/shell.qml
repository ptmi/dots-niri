//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Modals
import qs.Modules
import qs.Modules.AppDrawer
import qs.Modules.CentcomCenter
import qs.Modules.ControlCenter
import qs.Modules.ControlCenter.Network
import qs.Modules.Lock
import qs.Modules.Notifications.Center
import qs.Modules.Notifications.Popup
import qs.Modules.ProcessList
import qs.Modules.Settings
import qs.Modules.TopBar
import qs.Modules.Dock
import qs.Services

ShellRoot {
  id: root

  WallpaperBackground {}

  Lock {
    id: lock

    anchors.fill: parent
  }

  Variants {
    model: Quickshell.screens

    delegate: TopBar {
      modelData: item
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Dock {
      modelData: item
      contextMenu: dockContextMenuLoader.item ? dockContextMenuLoader.item : null
      windowsMenu: dockWindowsMenuLoader.item ? dockWindowsMenuLoader.item : null
      
      Component.onCompleted: {
        dockContextMenuLoader.active = true
        dockWindowsMenuLoader.active = true
      }
    }
  }

  LazyLoader {
    id: centcomPopoutLoader
    active: false
    
    CentcomPopout {
      id: centcomPopout
    }
  }

  LazyLoader {
    id: dockContextMenuLoader
    active: false
    
    DockContextMenu {
      id: dockContextMenu
    }
  }

  LazyLoader {
    id: dockWindowsMenuLoader
    active: false
    
    DockWindowsMenu {
      id: dockWindowsMenu
    }
  }

  LazyLoader {
    id: notificationCenterLoader
    active: false
    
    NotificationCenterPopout {
      id: notificationCenter
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: NotificationPopupManager {
      modelData: item
    }
  }

  LazyLoader {
    id: controlCenterLoader
    active: false
    
    ControlCenterPopout {
      id: controlCenterPopout

      onPowerActionRequested: (action, title, message) => {
                              powerConfirmModalLoader.active = true
                              if (powerConfirmModalLoader.item) {
                                powerConfirmModalLoader.item.powerConfirmAction = action
                                powerConfirmModalLoader.item.powerConfirmTitle = title
                                powerConfirmModalLoader.item.powerConfirmMessage = message
                                powerConfirmModalLoader.item.powerConfirmVisible = true
                              }
                            }
      onLockRequested: {
        lock.activate()
      }
    }
  }

  LazyLoader {
    id: wifiPasswordModalLoader
    active: false
    
    WifiPasswordModal {
      id: wifiPasswordModal
    }
  }

  LazyLoader {
    id: networkInfoModalLoader
    active: false
    
    NetworkInfoModal {
      id: networkInfoModal
    }
  }

  LazyLoader {
    id: batteryPopoutLoader
    active: false
    
    BatteryPopout {
      id: batteryPopout
    }
  }

  LazyLoader {
    id: powerMenuLoader
    active: false
    
    PowerMenu {
      id: powerMenu
    }
  }

  LazyLoader {
    id: powerConfirmModalLoader
    active: false
    
    PowerConfirmModal {
      id: powerConfirmModal
    }
  }

  LazyLoader {
    id: processListPopoutLoader
    active: false
    
    ProcessListPopout {
      id: processListPopout
    }
  }

  SettingsModal {
    id: settingsModal
  }

  LazyLoader {
    id: appDrawerLoader
    active: false
    
    AppDrawerPopout {
      id: appDrawerPopout
    }
  }

  SpotlightModal {
    id: spotlightModal
  }

  ClipboardHistoryModal {
    id: clipboardHistoryModalPopup
  }

  NotificationModal {
    id: notificationModal
  }

  LazyLoader {
    id: processListModalLoader

    active: false

    ProcessListModal {
      id: processListModal
    }
  }

  IpcHandler {
    function open() {
      processListModalLoader.active = true
      if (processListModalLoader.item)
        processListModalLoader.item.show()

      return "PROCESSLIST_OPEN_SUCCESS"
    }

    function close() {
      if (processListModalLoader.item)
        processListModalLoader.item.hide()

      return "PROCESSLIST_CLOSE_SUCCESS"
    }

    function toggle() {
      processListModalLoader.active = true
      if (processListModalLoader.item)
        processListModalLoader.item.toggle()

      return "PROCESSLIST_TOGGLE_SUCCESS"
    }

    target: "processlist"
  }

  Variants {
    model: Quickshell.screens


  }

  Variants {
    model: Quickshell.screens

    delegate: VolumePopup {
      modelData: item
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: MicMutePopup {
      modelData: item
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: BrightnessPopup {
      modelData: item
    }
  }
}
