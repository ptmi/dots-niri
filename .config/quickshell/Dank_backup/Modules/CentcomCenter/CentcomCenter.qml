import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services

PanelWindow {
    id: root

    readonly property bool hasActiveMedia: MprisController.activePlayer !== null
    property bool calendarVisible: false

    visible: calendarVisible
    onVisibleChanged: {
        if (visible && CalendarService)
            CalendarService.loadCurrentMonth();

    }
    implicitWidth: 480
    implicitHeight: 600
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Rectangle {
        id: mainContainer

        function calculateWidth() {
            let baseWidth = 320;
            if (leftWidgets.hasAnyWidgets)
                return Math.min(parent.width * 0.9, 600);

            return Math.min(parent.width * 0.7, 400);
        }

        function calculateHeight() {
            let contentHeight = Theme.spacingM * 2; // margins
            // Main row with widgets and calendar
            let widgetHeight = 160;
            // Media widget always present
            widgetHeight += 140 + Theme.spacingM;
            // Weather widget always present
            let calendarHeight = 300;
            let mainRowHeight = Math.max(widgetHeight, calendarHeight);
            contentHeight += mainRowHeight + Theme.spacingM;
            // Add events widget height - use calculated height instead of actual
            if (CalendarService && CalendarService.khalAvailable) {
                let hasEvents = eventsWidget.selectedDateEvents && eventsWidget.selectedDateEvents.length > 0;
                let eventsHeight = hasEvents ? Math.min(300, 80 + eventsWidget.selectedDateEvents.length * 60) : 120;
                contentHeight += eventsHeight;
            }
            return Math.min(contentHeight, parent.height * 0.9);
        }

        width: calculateWidth()
        height: calculateHeight()
        x: (parent.width - width) / 2
        y: Theme.barHeight + 4
        color: Theme.surfaceContainer
        radius: Theme.cornerRadiusLarge
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        layer.enabled: true
        opacity: calendarVisible ? 1 : 0
        scale: calendarVisible ? 1 : 0.92

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceTint.r, Theme.surfaceTint.g, Theme.surfaceTint.b, 0.04)
            radius: parent.radius

            SequentialAnimation on opacity {
                running: calendarVisible
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.08
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }

                NumberAnimation {
                    to: 0.02
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }

            }

        }

        // Update height when calendar service events change
        Connections {
            function onEventsByDateChanged() {
                mainContainer.height = mainContainer.calculateHeight();
            }

            function onKhalAvailableChanged() {
                mainContainer.height = mainContainer.calculateHeight();
            }

            target: CalendarService
            enabled: CalendarService !== null
        }

        // Update height when events widget's selectedDateEvents changes
        Connections {
            function onSelectedDateEventsChanged() {
                mainContainer.height = mainContainer.calculateHeight();
            }

            target: eventsWidget
            enabled: eventsWidget !== null
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            // Main row with widgets and calendar
            Row {
                width: parent.width
                height: {
                    let widgetHeight = 160; // Media widget always present
                    widgetHeight += 140 + Theme.spacingM; // Weather widget always present
                    let calendarHeight = 300;
                    return Math.max(widgetHeight, calendarHeight);
                }
                spacing: Theme.spacingM

                // Left section for widgets
                Column {
                    id: leftWidgets

                    property bool hasAnyWidgets: true // Always show media widget and weather widget

                    width: hasAnyWidgets ? parent.width * 0.45 : 0
                    height: childrenRect.height
                    spacing: Theme.spacingM
                    visible: hasAnyWidgets
                    anchors.top: parent.top

                    MediaPlayerWidget {
                        visible: true // Always visible - shows placeholder when no media
                        width: parent.width
                        height: 160
                    }

                    WeatherWidget {
                        visible: true // Always visible - shows placeholder when no weather
                        width: parent.width
                        height: 140
                    }

                }

                // Right section for calendar
                CalendarWidget {
                    id: calendarWidget

                    width: leftWidgets.hasAnyWidgets ? parent.width * 0.55 - Theme.spacingL : parent.width
                    height: parent.height
                }

            }

            // Full-width events widget below
            EventsWidget {
                id: eventsWidget

                width: parent.width
                selectedDate: calendarWidget.selectedDate
            }

        }

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 4
            shadowBlur: 0.5
            shadowColor: Qt.rgba(0, 0, 0, 0.15)
            shadowOpacity: 0.15
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.longDuration
                easing.type: Theme.emphasizedEasing
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.longDuration
                easing.type: Theme.emphasizedEasing
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.standardEasing
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            calendarVisible = false;
        }
    }

}
