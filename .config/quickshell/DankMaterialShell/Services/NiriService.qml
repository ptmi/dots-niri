pragma Singleton

pragma ComponentBehavior

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Workspace management
  property var workspaces: ({})
  property var allWorkspaces: []
  property int focusedWorkspaceIndex: 0
  property string focusedWorkspaceId: ""
  property var currentOutputWorkspaces: []
  property string currentOutput: ""

  // Window management
  property var windows: []
  property int focusedWindowIndex: -1
  property string focusedWindowTitle: "(No active window)"
  property string focusedWindowId: ""

  // Overview state
  property bool inOverview: false

  signal windowOpenedOrChanged(var windowData)

  // Feature availability
  property bool niriAvailable: false

  readonly property string socketPath: Quickshell.env("NIRI_SOCKET")

  Component.onCompleted: checkNiriAvailability()

  Process {
    id: niriCheck
    command: ["test", "-S", root.socketPath]

    onExited: exitCode => {
      root.niriAvailable = exitCode === 0
      if (root.niriAvailable) {
        eventStreamSocket.connected = true
      }
    }
  }

  function checkNiriAvailability() {
    niriCheck.running = true
  }

  Socket {
    id: eventStreamSocket
    path: root.socketPath
    connected: false

    onConnectionStateChanged: {
      if (connected) {
        write('"EventStream"\n')
      }
    }

    parser: SplitParser {
      onRead: line => {
        try {
          const event = JSON.parse(line)
          handleNiriEvent(event)
        } catch (e) {
          console.warn("NiriService: Failed to parse event:", line, e)
        }
      }
    }
  }

  Socket {
    id: requestSocket
    path: root.socketPath
    connected: root.niriAvailable
  }

  function handleNiriEvent(event) {
    if (event.WorkspacesChanged) {
      handleWorkspacesChanged(event.WorkspacesChanged)
    } else if (event.WorkspaceActivated) {
      handleWorkspaceActivated(event.WorkspaceActivated)
    } else if (event.WorkspaceActiveWindowChanged) {
      handleWorkspaceActiveWindowChanged(event.WorkspaceActiveWindowChanged)
    } else if (event.WindowsChanged) {
      handleWindowsChanged(event.WindowsChanged)
    } else if (event.WindowClosed) {
      handleWindowClosed(event.WindowClosed)
    } else if (event.WindowFocusChanged) {
      handleWindowFocusChanged(event.WindowFocusChanged)
    } else if (event.WindowOpenedOrChanged) {
      handleWindowOpenedOrChanged(event.WindowOpenedOrChanged)
    } else if (event.OverviewOpenedOrClosed) {
      handleOverviewChanged(event.OverviewOpenedOrClosed)
    }
  }

  function handleWorkspacesChanged(data) {
    const workspaces = {}

    for (const ws of data.workspaces) {
      workspaces[ws.id] = ws
    }

    root.workspaces = workspaces
    allWorkspaces = [...data.workspaces].sort((a, b) => a.idx - b.idx)

    focusedWorkspaceIndex = allWorkspaces.findIndex(w => w.is_focused)
    if (focusedWorkspaceIndex >= 0) {
      var focusedWs = allWorkspaces[focusedWorkspaceIndex]
      focusedWorkspaceId = focusedWs.id
      currentOutput = focusedWs.output || ""
    } else {
      focusedWorkspaceIndex = 0
      focusedWorkspaceId = ""
    }

    updateCurrentOutputWorkspaces()
  }

  function handleWorkspaceActivated(data) {
    const ws = root.workspaces[data.id]
    if (!ws)
      return
    const output = ws.output

    for (const id in root.workspaces) {
      const workspace = root.workspaces[id]
      const got_activated = workspace.id === data.id

      if (workspace.output === output) {
        workspace.is_active = got_activated
      }

      if (data.focused) {
        workspace.is_focused = got_activated
      }
    }

    focusedWorkspaceId = data.id
    focusedWorkspaceIndex = allWorkspaces.findIndex(w => w.id === data.id)

    if (focusedWorkspaceIndex >= 0) {
      currentOutput = allWorkspaces[focusedWorkspaceIndex].output || ""
    }

    allWorkspaces = Object.values(root.workspaces).sort((a, b) => a.idx - b.idx)

    updateCurrentOutputWorkspaces()
    workspacesChanged()
  }

  function handleWorkspaceActiveWindowChanged(data) {
    // Update the focused window when workspace's active window changes
    // This is crucial for handling floating window close scenarios
    if (data.active_window_id !== null && data.active_window_id !== undefined) {
      focusedWindowId = String(data.active_window_id)
      focusedWindowIndex = windows.findIndex(w => w.id == data.active_window_id)
      
      // Create new windows array with updated focus states to trigger property change
      let updatedWindows = []
      for (let i = 0; i < windows.length; i++) {
        let w = windows[i]
        let updatedWindow = {}
        for (let prop in w) {
          updatedWindow[prop] = w[prop]
        }
        updatedWindow.is_focused = (w.id == data.active_window_id)
        updatedWindows.push(updatedWindow)
      }
      windows = updatedWindows
      
      updateFocusedWindow()
    } else {
      // No active window in this workspace
      focusedWindowId = ""
      focusedWindowIndex = -1
      
      // Create new windows array with cleared focus states for this workspace
      let updatedWindows = []
      for (let i = 0; i < windows.length; i++) {
        let w = windows[i]
        let updatedWindow = {}
        for (let prop in w) {
          updatedWindow[prop] = w[prop]
        }
        updatedWindow.is_focused = w.workspace_id == data.workspace_id ? false : w.is_focused
        updatedWindows.push(updatedWindow)
      }
      windows = updatedWindows
      
      updateFocusedWindow()
    }
  }

  function handleWindowsChanged(data) {
    windows = [...data.windows].sort((a, b) => a.id - b.id)
    updateFocusedWindow()
  }

  function handleWindowClosed(data) {
    windows = windows.filter(w => w.id !== data.id)
    updateFocusedWindow()
  }

  function handleWindowFocusChanged(data) {
    if (data.id) {
      focusedWindowId = data.id
      focusedWindowIndex = windows.findIndex(w => w.id === data.id)
    } else {
      focusedWindowId = ""
      focusedWindowIndex = -1
    }
    updateFocusedWindow()
  }

  function handleWindowOpenedOrChanged(data) {
    if (!data.window)
      return

    const window = data.window
    const existingIndex = windows.findIndex(w => w.id === window.id)

    if (existingIndex >= 0) {
      let updatedWindows = [...windows]
      updatedWindows[existingIndex] = window
      windows = updatedWindows.sort((a, b) => a.id - b.id)
    } else {
      windows = [...windows, window].sort((a, b) => a.id - b.id)
    }

    if (window.is_focused) {
      focusedWindowId = window.id
      focusedWindowIndex = windows.findIndex(w => w.id === window.id)
    }

    updateFocusedWindow()

    windowOpenedOrChanged(window)
  }

  function handleOverviewChanged(data) {
    inOverview = data.is_open
  }

  function updateCurrentOutputWorkspaces() {
    if (!currentOutput) {
      currentOutputWorkspaces = allWorkspaces
      return
    }

    var outputWs = allWorkspaces.filter(w => w.output === currentOutput)
    currentOutputWorkspaces = outputWs
  }

  function updateFocusedWindow() {
    if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.length) {
      var focusedWin = windows[focusedWindowIndex]
      focusedWindowTitle = focusedWin.title || "(Unnamed window)"
    } else {
      focusedWindowTitle = "(No active window)"
    }
  }

  function send(request) {
    if (!niriAvailable || !requestSocket.connected)
      return false
    requestSocket.write(JSON.stringify(request) + "\n")
    return true
  }

  function switchToWorkspace(workspaceIndex) {
    return send({
                  "Action": {
                    "FocusWorkspace": {
                      "reference": {
                        "Index": workspaceIndex
                      }
                    }
                  }
                })
  }

  function getCurrentOutputWorkspaceNumbers() {
    return currentOutputWorkspaces.map(
          w => w.idx + 1) // niri uses 0-based, UI shows 1-based
  }

  function getCurrentWorkspaceNumber() {
    if (focusedWorkspaceIndex >= 0
        && focusedWorkspaceIndex < allWorkspaces.length) {
      return allWorkspaces[focusedWorkspaceIndex].idx + 1
    }
    return 1
  }

  function focusWindow(windowId) {
    return send({
                  "Action": {
                    "FocusWindow": {
                      "id": windowId
                    }
                  }
                })
  }

  function closeWindow(windowId) {
    return send({
                  "Action": {
                    "CloseWindow": {
                      "id": windowId
                    }
                  }
                })
  }

  function quit() {
    return send({
                  "Action": {
                    "Quit": {
                      "skip_confirmation": true
                    }
                  }
                })
  }

  function getWindowsByAppId(appId) {
    if (!appId)
      return []
    return windows.filter(w => w.app_id && w.app_id.toLowerCase(
                            ) === appId.toLowerCase())
  }

  function getRunningAppIds() {
    var appIds = new Set()
    windows.forEach(w => {
                      if (w.app_id) {
                        appIds.add(w.app_id.toLowerCase())
                      }
                    })
    return Array.from(appIds)
  }
}
