import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules.AppDrawer
import qs.Services
import qs.Widgets

PanelWindow {
  id: appDrawerPopout

  property bool isVisible: false
  property real triggerX: Theme.spacingL
  property real triggerY: Theme.barHeight + Theme.spacingXS
  property real triggerWidth: 40
  property string triggerSection: "left"
  property var triggerScreen: null

  function show() {
    appDrawerPopout.isVisible = true
    appLauncher.searchQuery = ""
  }

  function hide() {
    appDrawerPopout.isVisible = false
  }

  function toggle() {
    if (appDrawerPopout.isVisible)
      hide()
    else
      show()
  }

  function setTriggerPosition(x, y, width, section, screen) {
    triggerX = x
    triggerY = y
    triggerWidth = width
    triggerSection = section
    triggerScreen = screen
  }

  WlrLayershell.layer: WlrLayershell.Overlay
  WlrLayershell.exclusiveZone: -1
  WlrLayershell.keyboardFocus: isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.namespace: "quickshell-launcher"
  visible: isVisible
  color: "transparent"
  screen: triggerScreen

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  AppLauncher {
    id: appLauncher

    viewMode: SettingsData.appLauncherViewMode
    gridColumns: 4
    onAppLaunched: appDrawerPopout.hide()
    onViewModeSelected: function (mode) {
      SettingsData.setAppLauncherViewMode(mode)
    }
  }

  MouseArea {
    anchors.fill: parent
    enabled: appDrawerPopout.isVisible
    onClicked: function (mouse) {
      var localPos = mapToItem(launcherLoader, mouse.x, mouse.y)
      if (localPos.x < 0 || localPos.x > launcherLoader.width || localPos.y < 0
          || localPos.y > launcherLoader.height)
        appDrawerPopout.hide()
    }
  }

  Loader {
    id: launcherLoader

    readonly property real popupWidth: 520
    readonly property real popupHeight: 600
    readonly property real screenWidth: appDrawerPopout.screen ? appDrawerPopout.screen.width : Screen.width
    readonly property real screenHeight: appDrawerPopout.screen ? appDrawerPopout.screen.height : Screen.height
    readonly property real calculatedX: {
      var centerX = appDrawerPopout.triggerX + (appDrawerPopout.triggerWidth / 2) - (popupWidth / 2)

      if (centerX >= Theme.spacingM
          && centerX + popupWidth <= screenWidth - Theme.spacingM)
        return centerX

      if (centerX < Theme.spacingM)
        return Theme.spacingM

      if (centerX + popupWidth > screenWidth - Theme.spacingM)
        return screenWidth - popupWidth - Theme.spacingM

      return centerX
    }
    readonly property real calculatedY: appDrawerPopout.triggerY

    asynchronous: true
    active: appDrawerPopout.isVisible
    width: popupWidth
    height: popupHeight
    x: calculatedX
    y: calculatedY
    opacity: appDrawerPopout.isVisible ? 1 : 0
    scale: appDrawerPopout.isVisible ? 1 : 0.9

    Behavior on opacity {
      NumberAnimation {
        duration: Anims.durMed
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasized
      }
    }

    Behavior on scale {
      NumberAnimation {
        duration: Anims.durMed
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasized
      }
    }

    sourceComponent: Rectangle {
      id: launcherPanel

      color: Theme.popupBackground()
      radius: Theme.cornerRadius
      antialiasing: true
      smooth: true

      Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        color: "transparent"
        radius: parent.radius + 3
        border.color: Qt.rgba(0, 0, 0, 0.05)
        border.width: 1
        z: -3
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        color: "transparent"
        radius: parent.radius + 2
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        z: -2
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                              Theme.outline.b, 0.12)
        border.width: 1
        radius: parent.radius
        z: -1
      }

      Item {
        id: keyHandler

        anchors.fill: parent
        focus: true
        Component.onCompleted: {
          if (appDrawerPopout.isVisible)
            forceActiveFocus()
        }
        Keys.onPressed: function (event) {
          if (event.key === Qt.Key_Escape) {
            appDrawerPopout.hide()
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            appLauncher.selectNext()
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            appLauncher.selectPrevious()
            event.accepted = true
          } else if (event.key === Qt.Key_Right
                     && appLauncher.viewMode === "grid") {
            appLauncher.selectNextInRow()
            event.accepted = true
          } else if (event.key === Qt.Key_Left
                     && appLauncher.viewMode === "grid") {
            appLauncher.selectPreviousInRow()
            event.accepted = true
          } else if (event.key === Qt.Key_Return
                     || event.key === Qt.Key_Enter) {
            appLauncher.launchSelected()
            event.accepted = true
          } else if (!searchField.activeFocus && event.text
                     && event.text.length > 0 && event.text.match(
                       /[a-zA-Z0-9\\s]/)) {
            searchField.forceActiveFocus()
            searchField.insertText(event.text)
            event.accepted = true
          }
        }

        Column {
          width: parent.width - Theme.spacingL * 2
          height: parent.height - Theme.spacingL * 2
          x: Theme.spacingL
          y: Theme.spacingL
          spacing: Theme.spacingL

          Row {
            width: parent.width
            height: 40

            StyledText {
              anchors.verticalCenter: parent.verticalCenter
              text: "Applications"
              font.pixelSize: Theme.fontSizeLarge + 4
              font.weight: Font.Bold
              color: Theme.surfaceText
            }

            Item {
              width: parent.width - 200
              height: 1
            }

            StyledText {
              anchors.verticalCenter: parent.verticalCenter
              text: appLauncher.model.count + " apps"
              font.pixelSize: Theme.fontSizeMedium
              color: Theme.surfaceVariantText
            }
          }

          DankTextField {
            id: searchField

            width: parent.width
            height: 52
            cornerRadius: Theme.cornerRadius
            backgroundColor: Qt.rgba(Theme.surfaceVariant.r,
                                     Theme.surfaceVariant.g,
                                     Theme.surfaceVariant.b,
                                     Theme.getContentBackgroundAlpha() * 0.7)
            normalBorderColor: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                       Theme.outline.b, 0.3)
            focusedBorderColor: Theme.primary
            leftIconName: "search"
            leftIconSize: Theme.iconSize
            leftIconColor: Theme.surfaceVariantText
            leftIconFocusedColor: Theme.primary
            showClearButton: true
            font.pixelSize: Theme.fontSizeLarge
            enabled: appDrawerPopout.isVisible
            placeholderText: "Search applications..."
            ignoreLeftRightKeys: true
            keyForwardTargets: [keyHandler]
            onTextEdited: {
              appLauncher.searchQuery = text
            }
            Keys.onPressed: function (event) {
              if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                  && text.length > 0) {
                if (appLauncher.keyboardNavigationActive
                    && appLauncher.model.count > 0) {
                  appLauncher.launchSelected()
                } else if (appLauncher.model.count > 0) {
                  var firstApp = appLauncher.model.get(0)
                  appLauncher.launchApp(firstApp)
                }
                event.accepted = true
              } else if (event.key === Qt.Key_Down || event.key
                         === Qt.Key_Up || event.key === Qt.Key_Left || event.key
                         === Qt.Key_Right || ((event.key === Qt.Key_Return || event.key
                                               === Qt.Key_Enter) && text.length === 0)) {
                event.accepted = false
              }
            }
            Component.onCompleted: {
              if (appDrawerPopout.isVisible)
                searchField.forceActiveFocus()
            }

            Connections {
              function onIsVisibleChanged() {
                if (appDrawerPopout.isVisible)
                  Qt.callLater(function () {
                    searchField.forceActiveFocus()
                  })
                else
                  searchField.clearFocus()
              }

              target: appDrawerPopout
            }
          }

          Row {
            width: parent.width
            height: 40
            spacing: Theme.spacingM
            visible: searchField.text.length === 0

            Item {
              width: 200
              height: 36

              DankDropdown {
                anchors.fill: parent
                text: ""
                currentValue: appLauncher.selectedCategory
                options: appLauncher.categories
                optionIcons: appLauncher.categoryIcons
                onValueChanged: function (value) {
                  appLauncher.setCategory(value)
                }
              }
            }

            Item {
              width: parent.width - 300
              height: 1
            }

            Row {
              spacing: 4
              anchors.verticalCenter: parent.verticalCenter

              DankActionButton {
                buttonSize: 36
                circular: false
                iconName: "view_list"
                iconSize: 20
                iconColor: appLauncher.viewMode === "list" ? Theme.primary : Theme.surfaceText
                hoverColor: appLauncher.viewMode
                            === "list" ? Qt.rgba(Theme.primary.r,
                                                 Theme.primary.g,
                                                 Theme.primary.b,
                                                 0.12) : Qt.rgba(
                                           Theme.surfaceVariant.r,
                                           Theme.surfaceVariant.g,
                                           Theme.surfaceVariant.b, 0.08)
                backgroundColor: appLauncher.viewMode
                                 === "list" ? Qt.rgba(Theme.primary.r,
                                                      Theme.primary.g,
                                                      Theme.primary.b,
                                                      0.12) : "transparent"
                onClicked: {
                  appLauncher.setViewMode("list")
                }
              }

              DankActionButton {
                buttonSize: 36
                circular: false
                iconName: "grid_view"
                iconSize: 20
                iconColor: appLauncher.viewMode === "grid" ? Theme.primary : Theme.surfaceText
                hoverColor: appLauncher.viewMode
                            === "grid" ? Qt.rgba(Theme.primary.r,
                                                 Theme.primary.g,
                                                 Theme.primary.b,
                                                 0.12) : Qt.rgba(
                                           Theme.surfaceVariant.r,
                                           Theme.surfaceVariant.g,
                                           Theme.surfaceVariant.b, 0.08)
                backgroundColor: appLauncher.viewMode
                                 === "grid" ? Qt.rgba(Theme.primary.r,
                                                      Theme.primary.g,
                                                      Theme.primary.b,
                                                      0.12) : "transparent"
                onClicked: {
                  appLauncher.setViewMode("grid")
                }
              }
            }
          }

          Rectangle {
            width: parent.width
            height: {
              let usedHeight = 40 + Theme.spacingL
              usedHeight += 52 + Theme.spacingL
              usedHeight += (searchField.text.length === 0 ? 40 + Theme.spacingL : 0)
              return parent.height - usedHeight
            }
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                           Theme.surfaceVariant.b, 0.1)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                  Theme.outline.b, 0.05)
            border.width: 1

            DankListView {
              id: appList

              property int itemHeight: 72
              property int iconSize: 56
              property bool showDescription: true
              property int itemSpacing: Theme.spacingS
              property bool hoverUpdatesSelection: false
              property bool keyboardNavigationActive: appLauncher.keyboardNavigationActive

              signal keyboardNavigationReset
              signal itemClicked(int index, var modelData)
              signal itemHovered(int index)
              signal itemRightClicked(int index, var modelData, real mouseX, real mouseY)

              function ensureVisible(index) {
                if (index < 0 || index >= count)
                  return

                var itemY = index * (itemHeight + itemSpacing)
                var itemBottom = itemY + itemHeight
                if (itemY < contentY)
                  contentY = itemY
                else if (itemBottom > contentY + height)
                  contentY = itemBottom - height
              }

              anchors.fill: parent
              anchors.margins: Theme.spacingS
              visible: appLauncher.viewMode === "list"
              model: appLauncher.model
              currentIndex: appLauncher.selectedIndex
              clip: true
              spacing: itemSpacing
              focus: true
              interactive: true
              cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
              reuseItems: true

              onCurrentIndexChanged: {
                if (keyboardNavigationActive)
                  ensureVisible(currentIndex)
              }

              onItemClicked: function (index, modelData) {
                appLauncher.launchApp(modelData)
              }
              onItemHovered: function (index) {
                appLauncher.selectedIndex = index
              }
              onItemRightClicked: function (index, modelData, mouseX, mouseY) {
                contextMenu.show(mouseX, mouseY, modelData)
              }
              onKeyboardNavigationReset: {
                appLauncher.keyboardNavigationActive = false
              }

              ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
              }

              ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOff
              }

              delegate: Rectangle {
                width: ListView.view.width
                height: appList.itemHeight
                radius: Theme.cornerRadius
                color: ListView.isCurrentItem ? Theme.primaryPressed : listMouseArea.containsMouse ? Theme.primaryHoverLight : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.03)
                border.color: ListView.isCurrentItem ? Theme.primarySelected : Theme.outlineMedium
                border.width: ListView.isCurrentItem ? 2 : 1

                Row {
                  anchors.fill: parent
                  anchors.margins: Theme.spacingM
                  spacing: Theme.spacingL

                  Item {
                    width: appList.iconSize
                    height: appList.iconSize
                    anchors.verticalCenter: parent.verticalCenter

                    IconImage {
                      id: listIconImg

                      anchors.fill: parent
                      source: (model.icon) ? Quickshell.iconPath(
                                               model.icon,
                                               SettingsData.iconTheme === "System Default" ? "" : SettingsData.iconTheme) : ""
                      smooth: true
                      asynchronous: true
                      visible: status === Image.Ready
                    }

                    Rectangle {
                      anchors.fill: parent
                      visible: !listIconImg.visible
                      color: Theme.surfaceLight
                      radius: Theme.cornerRadius
                      border.width: 1
                      border.color: Theme.primarySelected

                      StyledText {
                        anchors.centerIn: parent
                        text: (model.name
                               && model.name.length > 0) ? model.name.charAt(
                                                             0).toUpperCase(
                                                             ) : "A"
                        font.pixelSize: appList.iconSize * 0.4
                        color: Theme.primary
                        font.weight: Font.Bold
                      }
                    }
                  }

                  Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - appList.iconSize - Theme.spacingL
                    spacing: Theme.spacingXS

                    StyledText {
                      width: parent.width
                      text: model.name || ""
                      font.pixelSize: Theme.fontSizeLarge
                      color: Theme.surfaceText
                      font.weight: Font.Medium
                      elide: Text.ElideRight
                    }

                    StyledText {
                      width: parent.width
                      text: model.comment || "Application"
                      font.pixelSize: Theme.fontSizeMedium
                      color: Theme.surfaceVariantText
                      elide: Text.ElideRight
                      visible: appList.showDescription && model.comment
                               && model.comment.length > 0
                    }
                  }
                }

                MouseArea {
                  id: listMouseArea

                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  z: 10
                  onEntered: {
                    if (appList.hoverUpdatesSelection
                        && !appList.keyboardNavigationActive)
                      appList.currentIndex = index

                    appList.itemHovered(index)
                  }
                  onPositionChanged: {
                    appList.keyboardNavigationReset()
                  }
                  onClicked: mouse => {
                               if (mouse.button === Qt.LeftButton) {
                                 appList.itemClicked(index, model)
                               } else if (mouse.button === Qt.RightButton) {
                                 var globalPos = mapToGlobal(mouse.x, mouse.y)
                                 appList.itemRightClicked(index, model,
                                                          globalPos.x,
                                                          globalPos.y)
                               }
                             }
                }
              }
            }

            DankGridView {
              id: appGrid

              property int currentIndex: appLauncher.selectedIndex
              property int columns: 4
              property bool adaptiveColumns: false
              property int minCellWidth: 120
              property int maxCellWidth: 160
              property int cellPadding: 8
              property real iconSizeRatio: 0.6
              property int maxIconSize: 56
              property int minIconSize: 32
              property bool hoverUpdatesSelection: false
              property bool keyboardNavigationActive: appLauncher.keyboardNavigationActive
              property int baseCellWidth: adaptiveColumns ? Math.max(
                                                              minCellWidth,
                                                              Math.min(
                                                                maxCellWidth,
                                                                width / columns)) : (width - Theme.spacingS * 2) / columns
              property int baseCellHeight: baseCellWidth + 20
              property int actualColumns: adaptiveColumns ? Math.floor(
                                                              width / cellWidth) : columns
              property int remainingSpace: width - (actualColumns * cellWidth)

              signal keyboardNavigationReset
              signal itemClicked(int index, var modelData)
              signal itemHovered(int index)
              signal itemRightClicked(int index, var modelData, real mouseX, real mouseY)

              function ensureVisible(index) {
                if (index < 0 || index >= count)
                  return

                var itemY = Math.floor(index / actualColumns) * cellHeight
                var itemBottom = itemY + cellHeight
                if (itemY < contentY)
                  contentY = itemY
                else if (itemBottom > contentY + height)
                  contentY = itemBottom - height
              }

              anchors.fill: parent
              anchors.margins: Theme.spacingS
              visible: appLauncher.viewMode === "grid"
              model: appLauncher.model
              clip: true
              cellWidth: baseCellWidth
              cellHeight: baseCellHeight
              leftMargin: Math.max(Theme.spacingS, remainingSpace / 2)
              rightMargin: leftMargin
              focus: true
              interactive: true
              cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
              reuseItems: true

              onCurrentIndexChanged: {
                if (keyboardNavigationActive)
                  ensureVisible(currentIndex)
              }

              onItemClicked: function (index, modelData) {
                appLauncher.launchApp(modelData)
              }
              onItemHovered: function (index) {
                appLauncher.selectedIndex = index
              }
              onItemRightClicked: function (index, modelData, mouseX, mouseY) {
                contextMenu.show(mouseX, mouseY, modelData)
              }
              onKeyboardNavigationReset: {
                appLauncher.keyboardNavigationActive = false
              }

              ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
              }

              ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOff
              }

              delegate: Rectangle {
                width: appGrid.cellWidth - appGrid.cellPadding
                height: appGrid.cellHeight - appGrid.cellPadding
                radius: Theme.cornerRadius
                color: appGrid.currentIndex === index ? Theme.primaryPressed : gridMouseArea.containsMouse ? Theme.primaryHoverLight : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.03)
                border.color: appGrid.currentIndex
                              === index ? Theme.primarySelected : Theme.outlineMedium
                border.width: appGrid.currentIndex === index ? 2 : 1

                Column {
                  anchors.centerIn: parent
                  spacing: Theme.spacingS

                  Item {
                    property int iconSize: Math.min(
                                             appGrid.maxIconSize, Math.max(
                                               appGrid.minIconSize,
                                               appGrid.cellWidth * appGrid.iconSizeRatio))

                    width: iconSize
                    height: iconSize
                    anchors.horizontalCenter: parent.horizontalCenter

                    IconImage {
                      id: gridIconImg

                      anchors.fill: parent
                      source: (model.icon) ? Quickshell.iconPath(
                                               model.icon,
                                               SettingsData.iconTheme === "System Default" ? "" : SettingsData.iconTheme) : ""
                      smooth: true
                      asynchronous: true
                      visible: status === Image.Ready
                    }

                    Rectangle {
                      anchors.fill: parent
                      visible: !gridIconImg.visible
                      color: Theme.surfaceLight
                      radius: Theme.cornerRadius
                      border.width: 1
                      border.color: Theme.primarySelected

                      StyledText {
                        anchors.centerIn: parent
                        text: (model.name
                               && model.name.length > 0) ? model.name.charAt(
                                                             0).toUpperCase(
                                                             ) : "A"
                        font.pixelSize: Math.min(28, parent.width * 0.5)
                        color: Theme.primary
                        font.weight: Font.Bold
                      }
                    }
                  }

                  StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: appGrid.cellWidth - 12
                    text: model.name || ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                  }
                }

                MouseArea {
                  id: gridMouseArea

                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  z: 10
                  onEntered: {
                    if (appGrid.hoverUpdatesSelection
                        && !appGrid.keyboardNavigationActive)
                      appGrid.currentIndex = index

                    appGrid.itemHovered(index)
                  }
                  onPositionChanged: {
                    appGrid.keyboardNavigationReset()
                  }
                  onClicked: mouse => {
                               if (mouse.button === Qt.LeftButton) {
                                 appGrid.itemClicked(index, model)
                               } else if (mouse.button === Qt.RightButton) {
                                 var globalPos = mapToGlobal(mouse.x, mouse.y)
                                 appGrid.itemRightClicked(index, model,
                                                          globalPos.x,
                                                          globalPos.y)
                               }
                             }
                }
              }
            }
          }
        }
      }
    }
  }

  Popup {
    id: contextMenu

    property var currentApp: null

    function show(x, y, app) {
      currentApp = app
      if (!contextMenu.parent && typeof Overlay !== "undefined"
          && Overlay.overlay)
        contextMenu.parent = Overlay.overlay

      const menuWidth = 180
      const menuHeight = menuColumn.implicitHeight + Theme.spacingS * 2
      const screenWidth = Screen.width
      const screenHeight = Screen.height
      let finalX = x
      let finalY = y
      if (x + menuWidth > screenWidth - 20)
        finalX = x - menuWidth

      if (y + menuHeight > screenHeight - 20)
        finalY = y - menuHeight

      contextMenu.x = Math.max(20, finalX)
      contextMenu.y = Math.max(20, finalY)
      open()
    }

    width: 180
    height: menuColumn.implicitHeight + Theme.spacingS * 2
    padding: 0
    modal: false
    closePolicy: Popup.CloseOnEscape
    onClosed: {
      closePolicy = Popup.CloseOnEscape
    }
    onOpened: {
      outsideClickTimer.start()
    }

    Timer {
      id: outsideClickTimer

      interval: 100
      onTriggered: {
        contextMenu.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside
      }
    }

    background: Rectangle {
      color: "transparent"
    }

    contentItem: Rectangle {
      color: Theme.popupBackground()
      radius: Theme.cornerRadius
      border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                            Theme.outline.b, 0.08)
      border.width: 1

      Column {
        id: menuColumn

        anchors.fill: parent
        anchors.margins: Theme.spacingS
        spacing: 1

        Rectangle {
          width: parent.width
          height: 32
          radius: Theme.cornerRadius
          color: pinMouseArea.containsMouse ? Qt.rgba(Theme.primary.r,
                                                      Theme.primary.g,
                                                      Theme.primary.b,
                                                      0.12) : "transparent"

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingS
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingS

            DankIcon {
              name: {
                if (!contextMenu.currentApp
                    || !contextMenu.currentApp.desktopEntry)
                  return "push_pin"

                var appId = contextMenu.currentApp.desktopEntry.id
                    || contextMenu.currentApp.desktopEntry.execString || ""
                return SessionData.isPinnedApp(appId) ? "keep_off" : "push_pin"
              }
              size: Theme.iconSize - 2
              color: Theme.surfaceText
              opacity: 0.7
              anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
              text: {
                if (!contextMenu.currentApp
                    || !contextMenu.currentApp.desktopEntry)
                  return "Pin to Dock"

                var appId = contextMenu.currentApp.desktopEntry.id
                    || contextMenu.currentApp.desktopEntry.execString || ""
                return SessionData.isPinnedApp(
                      appId) ? "Unpin from Dock" : "Pin to Dock"
              }
              font.pixelSize: Theme.fontSizeSmall
              color: Theme.surfaceText
              font.weight: Font.Normal
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: pinMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (!contextMenu.currentApp
                  || !contextMenu.currentApp.desktopEntry)
                return

              var appId = contextMenu.currentApp.desktopEntry.id
                  || contextMenu.currentApp.desktopEntry.execString || ""
              if (SessionData.isPinnedApp(appId))
                SessionData.removePinnedApp(appId)
              else
                SessionData.addPinnedApp(appId)
              contextMenu.close()
            }
          }
        }

        Rectangle {
          width: parent.width - Theme.spacingS * 2
          height: 5
          anchors.horizontalCenter: parent.horizontalCenter
          color: "transparent"

          Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 1
            color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                           Theme.outline.b, 0.2)
          }
        }

        Rectangle {
          width: parent.width
          height: 32
          radius: Theme.cornerRadius
          color: launchMouseArea.containsMouse ? Qt.rgba(Theme.primary.r,
                                                         Theme.primary.g,
                                                         Theme.primary.b,
                                                         0.12) : "transparent"

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingS
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingS

            DankIcon {
              name: "launch"
              size: Theme.iconSize - 2
              color: Theme.surfaceText
              opacity: 0.7
              anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
              text: "Launch"
              font.pixelSize: Theme.fontSizeSmall
              color: Theme.surfaceText
              font.weight: Font.Normal
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: launchMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (contextMenu.currentApp)
                appLauncher.launchApp(contextMenu.currentApp)

              contextMenu.close()
            }
          }
        }
      }
    }
  }
}
