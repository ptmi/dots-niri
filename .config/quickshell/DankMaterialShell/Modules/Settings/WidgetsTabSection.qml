import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services

Column {
  id: root

  property var items: []
  property var allWidgets: []
  property string title: ""
  property string titleIcon: "widgets"
  property string sectionId: ""

  signal itemEnabledChanged(string sectionId, string itemId, bool enabled)
  signal itemOrderChanged(var newOrder)
  signal addWidget(string sectionId)
  signal removeWidget(string sectionId, int widgetIndex)
  signal spacerSizeChanged(string sectionId, string itemId, int newSize)
  signal compactModeChanged(string widgetId, var value)
  signal gpuSelectionChanged(string sectionId, int widgetIndex, int selectedIndex)

  width: parent.width
  height: implicitHeight
  spacing: Theme.spacingM

  Row {
    width: parent.width
    spacing: Theme.spacingM

    DankIcon {
      name: root.titleIcon
      size: Theme.iconSize
      color: Theme.primary
      anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
      text: root.title
      font.pixelSize: Theme.fontSizeLarge
      font.weight: Font.Medium
      color: Theme.surfaceText
      anchors.verticalCenter: parent.verticalCenter
    }

    Item {
      width: parent.width - 60
      height: 1
    }
  }

  Column {
    id: itemsList

    width: parent.width
    spacing: Theme.spacingS

    Repeater {
      model: root.items

      delegate: Item {
        id: delegateItem

        property bool held: dragArea.pressed
        property real originalY: y

        width: itemsList.width
        height: 70
        z: held ? 2 : 1

        Rectangle {
          id: itemBackground

          anchors.fill: parent
          anchors.margins: 2
          radius: Theme.cornerRadius
          color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                         Theme.surfaceContainer.b, 0.8)
          border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                Theme.outline.b, 0.2)
          border.width: 1

          DankIcon {
            name: "drag_indicator"
            size: Theme.iconSize - 4
            color: Theme.outline
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM + 8
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
          }

          DankIcon {
            name: modelData.icon
            size: Theme.iconSize
            color: modelData.enabled ? Theme.primary : Theme.outline
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM * 2 + 40
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM * 3 + 40 + Theme.iconSize
            anchors.right: actionButtons.left
            anchors.rightMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            StyledText {
              text: modelData.text
              font.pixelSize: Theme.fontSizeMedium
              font.weight: Font.Medium
              color: modelData.enabled ? Theme.surfaceText : Theme.outline
              elide: Text.ElideRight
              width: parent.width
            }

            StyledText {
              text: modelData.description
              font.pixelSize: Theme.fontSizeSmall
              color: modelData.enabled ? Theme.outline : Qt.rgba(
                                           Theme.outline.r, Theme.outline.g,
                                           Theme.outline.b, 0.6)
              elide: Text.ElideRight
              width: parent.width
              wrapMode: Text.WordWrap
            }
          }

          Row {
            id: actionButtons

            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXS

            Item {
              width: 120
              height: 32
              visible: modelData.id === "gpuTemp"

              DankDropdown {
                id: gpuDropdown
                anchors.fill: parent
                currentValue: {
                  var selectedIndex = modelData.selectedGpuIndex
                      !== undefined ? modelData.selectedGpuIndex : 0
                  if (DgopService.availableGpus
                      && DgopService.availableGpus.length > selectedIndex
                      && selectedIndex >= 0) {
                    var gpu = DgopService.availableGpus[selectedIndex]
                    return gpu.driver.toUpperCase()
                  }
                  return DgopService.availableGpus
                      && DgopService.availableGpus.length
                      > 0 ? DgopService.availableGpus[0].driver.toUpperCase() : ""
                }
                options: {
                  var gpuOptions = []
                  if (DgopService.availableGpus
                      && DgopService.availableGpus.length > 0) {
                    for (var i = 0; i < DgopService.availableGpus.length; i++) {
                      var gpu = DgopService.availableGpus[i]
                      gpuOptions.push(gpu.driver.toUpperCase())
                    }
                  }
                  return gpuOptions
                }
                onValueChanged: value => {
                                  var gpuIndex = options.indexOf(value)
                                  if (gpuIndex >= 0) {
                                    root.gpuSelectionChanged(root.sectionId,
                                                             index, gpuIndex)
                                  }
                                }
              }
            }

            Item {
              width: 32
              height: 32
              visible: (modelData.warning !== undefined && modelData.warning !== "") && (modelData.id === "cpuUsage" || modelData.id === "memUsage" || modelData.id === "cpuTemp" || modelData.id === "gpuTemp")

              DankIcon {
                name: "warning"
                size: 20
                color: Theme.error
                anchors.centerIn: parent
                opacity: warningArea.containsMouse ? 1.0 : 0.8
              }

              MouseArea {
                id: warningArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
              }

              Rectangle {
                id: warningTooltip
                
                property string warningText: (modelData.warning !== undefined && modelData.warning !== "") ? modelData.warning : ""
                
                width: Math.min(250, warningTooltipText.implicitWidth) + Theme.spacingM * 2
                height: warningTooltipText.implicitHeight + Theme.spacingS * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainer
                border.color: Theme.outline
                border.width: 1
                visible: warningArea.containsMouse && warningText !== ""
                opacity: visible ? 1 : 0
                x: -width - Theme.spacingS
                y: (parent.height - height) / 2
                z: 100

                StyledText {
                  id: warningTooltipText
                  anchors.centerIn: parent
                  anchors.margins: Theme.spacingS
                  text: warningTooltip.warningText
                  font.pixelSize: Theme.fontSizeSmall
                  color: Theme.surfaceText
                  width: Math.min(250, implicitWidth)
                  wrapMode: Text.WordWrap
                }

                Behavior on opacity {
                  NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                  }
                }
              }
            }

            Row {
              spacing: Theme.spacingXS
              visible: modelData.id === "clock" || modelData.id === "music"
              
              DankActionButton {
                id: smallSizeButton
                buttonSize: 28
                visible: modelData.id === "music"
                iconName: "photo_size_select_small"
                iconSize: 16
                iconColor: SettingsData.mediaSize === 0 ? Theme.primary : Theme.outline
                onClicked: {
                  root.compactModeChanged("music", 0)
                }
              }
              
              DankActionButton {
                id: mediumSizeButton
                buttonSize: 28
                visible: modelData.id === "music"
                iconName: "photo_size_select_actual"
                iconSize: 16
                iconColor: SettingsData.mediaSize === 1 ? Theme.primary : Theme.outline
                onClicked: {
                  root.compactModeChanged("music", 1)
                }
              }
              
              DankActionButton {
                id: largeSizeButton
                buttonSize: 28
                visible: modelData.id === "music"
                iconName: "photo_size_select_large"
                iconSize: 16
                iconColor: SettingsData.mediaSize === 2 ? Theme.primary : Theme.outline
                onClicked: {
                  root.compactModeChanged("music", 2)
                }
              }
              
              DankActionButton {
                id: compactModeButton
                buttonSize: 28
                visible: modelData.id === "clock"
                iconName: SettingsData.clockCompactMode ? "zoom_out" : "zoom_in"
                iconSize: 16
                iconColor: SettingsData.clockCompactMode ? Theme.primary : Theme.outline
                onClicked: {
                  root.compactModeChanged("clock", !SettingsData.clockCompactMode)
                }
              }

              Rectangle {
                id: compactModeTooltip
                width: tooltipText.contentWidth + Theme.spacingM * 2
                height: tooltipText.contentHeight + Theme.spacingS * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainer
                border.color: Theme.outline
                border.width: 1
                visible: false
                opacity: visible ? 1 : 0
                x: -width - Theme.spacingS
                y: (parent.height - height) / 2
                z: 100

                StyledText {
                  id: tooltipText
                  anchors.centerIn: parent
                  text: "Compact Mode"
                  font.pixelSize: Theme.fontSizeSmall
                  color: Theme.surfaceText
                }

                Behavior on opacity {
                  NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                  }
                }
              }
            }

            DankActionButton {
              visible: modelData.id !== "spacer"
              buttonSize: 32
              iconName: modelData.enabled ? "visibility" : "visibility_off"
              iconSize: 18
              iconColor: modelData.enabled ? Theme.primary : Theme.outline
              onClicked: {
                root.itemEnabledChanged(root.sectionId, modelData.id,
                                        !modelData.enabled)
              }
            }

            Row {
              visible: modelData.id === "spacer"
              spacing: Theme.spacingXS
              anchors.verticalCenter: parent.verticalCenter

              DankActionButton {
                buttonSize: 24
                iconName: "remove"
                iconSize: 14
                iconColor: Theme.outline
                onClicked: {
                  var currentSize = modelData.size || 20
                  var newSize = Math.max(5, currentSize - 5)
                  root.spacerSizeChanged(root.sectionId, modelData.id, newSize)
                }
              }

              StyledText {
                text: (modelData.size || 20).toString()
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
              }

              DankActionButton {
                buttonSize: 24
                iconName: "add"
                iconSize: 14
                iconColor: Theme.outline
                onClicked: {
                  var currentSize = modelData.size || 20
                  var newSize = Math.min(5000, currentSize + 5)
                  root.spacerSizeChanged(root.sectionId, modelData.id, newSize)
                }
              }
            }

            DankActionButton {
              buttonSize: 32
              iconName: "close"
              iconSize: 18
              iconColor: Theme.error
              onClicked: {
                root.removeWidget(root.sectionId, index)
              }
            }
          }

          MouseArea {
            id: dragArea

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 60
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor
            drag.target: held ? delegateItem : undefined
            drag.axis: Drag.YAxis
            drag.minimumY: -delegateItem.height
            drag.maximumY: itemsList.height
            preventStealing: true
            onPressed: {
              delegateItem.z = 2
              delegateItem.originalY = delegateItem.y
            }
            onReleased: {
              delegateItem.z = 1
              if (drag.active) {
                var newIndex = Math.round(
                      delegateItem.y / (delegateItem.height + itemsList.spacing))
                newIndex = Math.max(0, Math.min(newIndex,
                                                root.items.length - 1))
                if (newIndex !== index) {
                  var newItems = root.items.slice()
                  var draggedItem = newItems.splice(index, 1)[0]
                  newItems.splice(newIndex, 0, draggedItem)
                  root.itemOrderChanged(newItems.map(item => {
                                                       return ({
                                                                 "id": item.id,
                                                                 "enabled": item.enabled,
                                                                 "size": item.size
                                                               })
                                                     }))
                }
              }
              delegateItem.x = 0
              delegateItem.y = delegateItem.originalY
            }
          }

          Behavior on y {
            enabled: !dragArea.held && !dragArea.drag.active

            NumberAnimation {
              duration: Theme.shortDuration
              easing.type: Theme.standardEasing
            }
          }
        }
      }
    }
  }

  Rectangle {
    width: 200
    height: 40
    radius: Theme.cornerRadius
    color: addButtonArea.containsMouse ? Theme.primaryContainer : Qt.rgba(
                                           Theme.surfaceVariant.r,
                                           Theme.surfaceVariant.g,
                                           Theme.surfaceVariant.b, 0.3)
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                          Theme.outline.b, 0.2)
    border.width: 1
    anchors.horizontalCenter: parent.horizontalCenter

    StyledText {
      text: "Add Widget"
      font.pixelSize: Theme.fontSizeSmall
      font.weight: Font.Medium
      color: Theme.primary
      anchors.verticalCenter: parent.verticalCenter
      anchors.centerIn: parent
    }

    MouseArea {
      id: addButtonArea

      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        root.addWidget(root.sectionId)
      }
    }

    Behavior on color {
      ColorAnimation {
        duration: Theme.shortDuration
        easing.type: Theme.standardEasing
      }
    }
  }
}
