import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    // For recents, use the recent apps from Prefs and filter out non-existent ones

    id: launcher

    property bool isVisible: false
    // App management
    property var categories: AppSearchService.getAllCategories()
    property string selectedCategory: "All"
    property var recentApps: Prefs.recentlyUsedApps.map((recentApp) => {
        var app = AppSearchService.getAppByExec(recentApp.exec);
        return app && !app.noDisplay ? app : null;
    }).filter((app) => {
        return app !== null;
    })
    property var pinnedApps: ["firefox", "code", "terminal", "file-manager"]
    property bool showCategories: false
    property string viewMode: Prefs.appLauncherViewMode // "list" or "grid"
    property int selectedIndex: 0

    function updateFilteredModel() {
        filteredModel.clear();
        selectedIndex = 0;
        var apps = [];
        var searchQuery = searchField ? searchField.text : "";
        // Get apps based on category and search
        if (searchQuery.length > 0) {
            // Search across all apps or category
            var baseApps = selectedCategory === "All" ? AppSearchService.applications : selectedCategory === "Recents" ? recentApps.map((recentApp) => {
                return AppSearchService.getAppByExec(recentApp.exec);
            }).filter((app) => {
                return app !== null && !app.noDisplay;
            }) : AppSearchService.getAppsInCategory(selectedCategory);
            if (baseApps && baseApps.length > 0) {
                var searchResults = AppSearchService.searchApplications(searchQuery);
                apps = searchResults.filter((app) => {
                    return baseApps.includes(app);
                });
            }
        } else {
            // Just category filter
            if (selectedCategory === "Recents")
                apps = recentApps.map((recentApp) => {
                return AppSearchService.getAppByExec(recentApp.exec);
            }).filter((app) => {
                return app !== null && !app.noDisplay;
            });
            else
                apps = AppSearchService.getAppsInCategory(selectedCategory) || [];
        }
        // Add to model with null checks
        if (apps && apps.length > 0)
            apps.forEach((app) => {
            if (app)
                filteredModel.append({
                "name": app.name || "",
                "exec": app.execString || "",
                "icon": app.icon || "application-x-executable",
                "comment": app.comment || "",
                "categories": app.categories || [],
                "desktopEntry": app
            });

        });

    }

    function selectNext() {
        if (filteredModel.count > 0) {
            if (viewMode === "grid") {
                // Grid navigation: move by columns
                var columnsCount = appGrid.columns || 4;
                var newIndex = Math.min(selectedIndex + columnsCount, filteredModel.count - 1);
                console.log("Grid navigation DOWN: from", selectedIndex, "to", newIndex, "columns:", columnsCount);
                selectedIndex = newIndex;
            } else {
                // List navigation: next item
                selectedIndex = (selectedIndex + 1) % filteredModel.count;
            }
        }
    }

    function selectPrevious() {
        if (filteredModel.count > 0) {
            if (viewMode === "grid") {
                // Grid navigation: move by columns
                var columnsCount = appGrid.columns || 4;
                var newIndex = Math.max(selectedIndex - columnsCount, 0);
                console.log("Grid navigation UP: from", selectedIndex, "to", newIndex, "columns:", columnsCount);
                selectedIndex = newIndex;
            } else {
                // List navigation: previous item
                selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : filteredModel.count - 1;
            }
        }
    }

    function selectNextInRow() {
        if (filteredModel.count > 0 && viewMode === "grid")
            selectedIndex = Math.min(selectedIndex + 1, filteredModel.count - 1);

    }

    function selectPreviousInRow() {
        if (filteredModel.count > 0 && viewMode === "grid")
            selectedIndex = Math.max(selectedIndex - 1, 0);

    }

    function launchSelected() {
        if (filteredModel.count > 0 && selectedIndex >= 0 && selectedIndex < filteredModel.count) {
            var selectedApp = filteredModel.get(selectedIndex);
            if (selectedApp.desktopEntry) {
                Prefs.addRecentApp(selectedApp.desktopEntry);
                selectedApp.desktopEntry.execute();
            } else {
                launcher.launchApp(selectedApp.exec);
            }
            launcher.hide();
        }
    }

    function launchApp(exec) {
        // Try to find the desktop entry
        var app = AppSearchService.getAppByExec(exec);
        if (app) {
            app.execute();
        } else {
            // Fallback to direct execution
            var cleanExec = exec.replace(/%[fFuU]/g, "").trim();
            console.log("Launching app directly:", cleanExec);
            Quickshell.execDetached(["sh", "-c", cleanExec]);
        }
    }

    function show() {
        launcher.isVisible = true;
        searchField.enabled = true;
        searchDebounceTimer.stop(); // Stop any pending search
        updateFilteredModel();
    }

    function hide() {
        searchField.enabled = false; // Disable before hiding to prevent Wayland warnings
        launcher.isVisible = false;
        searchDebounceTimer.stop(); // Stop any pending search
        searchField.text = "";
        showCategories = false;
    }

    function toggle() {
        if (launcher.isVisible)
            hide();
        else
            show();
    }

    // Proper layer shell configuration
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"
    visible: isVisible
    color: "transparent"
    Component.onCompleted: {
        var allCategories = AppSearchService.getAllCategories();
        // Insert "Recents" after "All"
        categories = ["All", "Recents"].concat(allCategories.filter((cat) => {
            return cat !== "All";
        }));
        updateFilteredModel();
    }

    // Full screen overlay setup for proper focus
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Search debouncing
    Timer {
        id: searchDebounceTimer

        interval: 50
        repeat: false
        onTriggered: updateFilteredModel()
    }

    ListModel {
        id: filteredModel
    }

    // Background dim with click to close
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        opacity: launcher.isVisible ? 1 : 0
        visible: launcher.isVisible

        MouseArea {
            anchors.fill: parent
            enabled: launcher.isVisible
            onClicked: launcher.hide()
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }

        }

    }

    Component {
        id: iconComponent

        Item {
            property var appData: parent.modelData || {
            }

            IconImage {
                id: iconImg

                anchors.fill: parent
                source: (appData && appData.icon) ? Quickshell.iconPath(appData.icon, "") : ""
                smooth: true
                asynchronous: true
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                visible: !iconImg.visible
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                radius: Theme.cornerRadiusLarge
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: (appData && appData.name && appData.name.length > 0) ? appData.name.charAt(0).toUpperCase() : "A"
                    font.pixelSize: 28
                    color: Theme.primary
                    font.weight: Font.Bold
                }

            }

        }

    }

    // Main launcher panel with enhanced design
    Rectangle {
        id: launcherPanel

        width: 520
        height: 600
        color: Theme.popupBackground()
        radius: Theme.cornerRadiusXLarge
        opacity: launcher.isVisible ? 1 : 0
        // Animated entrance with spring effect
        transform: [
            Scale {
                id: scaleTransform

                origin.x: 0
                origin.y: 0
                xScale: launcher.isVisible ? 1 : 0.92
                yScale: launcher.isVisible ? 1 : 0.92

                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }

                }

                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }

                }

            },
            Translate {
                id: translateTransform

                x: launcher.isVisible ? 0 : -30
                y: launcher.isVisible ? 0 : -15

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }

                }

            }
        ]

        anchors {
            top: parent.top
            left: parent.left
            topMargin: Theme.barHeight + Theme.spacingXS
            leftMargin: Theme.spacingL
        }

        // Material 3 elevation with multiple layers
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
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1
            radius: parent.radius
            z: -1
        }

        // Content with focus management
        Item {
            anchors.fill: parent
            focus: true
            Component.onCompleted: {
                if (launcher.isVisible)
                    forceActiveFocus();

            }
            // Handle keyboard shortcuts
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    launcher.hide();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    selectNext();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    selectPrevious();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right && viewMode === "grid") {
                    selectNextInRow();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left && viewMode === "grid") {
                    selectPreviousInRow();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    launchSelected();
                    event.accepted = true;
                } else if (event.text && event.text.length > 0 && event.text.match(/[a-zA-Z0-9\s]/)) {
                    // User started typing, focus search field and pass the character
                    searchField.forceActiveFocus();
                    searchField.text = event.text;
                    event.accepted = true;
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingXL
                spacing: Theme.spacingL

                // Header section
                Row {
                    width: parent.width
                    height: 40

                    // App launcher title
                    Text {
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

                    // Quick stats
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: filteredModel.count + " apps"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                    }

                }

                // Enhanced search field
                DankTextField {
                    id: searchField

                    width: parent.width
                    height: 52
                    cornerRadius: Theme.cornerRadiusLarge
                    backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.7)
                    normalBorderColor: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                    focusedBorderColor: Theme.primary
                    leftIconName: "search"
                    leftIconSize: Theme.iconSize
                    leftIconColor: Theme.surfaceVariantText
                    leftIconFocusedColor: Theme.primary
                    showClearButton: true
                    font.pixelSize: Theme.fontSizeLarge
                    enabled: launcher.isVisible
                    placeholderText: "Search applications..."
                    onTextEdited: {
                        searchDebounceTimer.restart();
                    }
                    Keys.onPressed: function(event) {
                        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && filteredModel.count && text.length > 0) {
                            // Launch first app when typing in search field
                            var firstApp = filteredModel.get(0);
                            if (firstApp.desktopEntry) {
                                Prefs.addRecentApp(firstApp.desktopEntry);
                                firstApp.desktopEntry.execute();
                            } else {
                                launcher.launchApp(firstApp.exec);
                            }
                            launcher.hide();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up || (event.key === Qt.Key_Left && viewMode === "grid") || (event.key === Qt.Key_Right && viewMode === "grid") || ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && text.length === 0)) {
                            // Pass navigation keys and enter (when not searching) to main handler
                            event.accepted = false;
                        }
                    }

                    Connections {
                        function onVisibleChanged() {
                            if (launcher.visible)
                                searchField.forceActiveFocus();
                            else
                                searchField.clearFocus();
                        }

                        target: launcher
                    }

                }

                // Category filter and view mode controls
                Row {
                    width: parent.width
                    height: 40
                    spacing: Theme.spacingM
                    visible: searchField.text.length === 0

                    // Category filter
                    Rectangle {
                        width: 200
                        height: 36
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.4)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DankIcon {
                                name: "category"
                                size: 18
                                color: Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: selectedCategory
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                font.weight: Font.Medium
                            }

                        }

                        DankIcon {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            name: showCategories ? "expand_less" : "expand_more"
                            size: 18
                            color: Theme.surfaceVariantText
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showCategories = !showCategories
                        }

                    }

                    Item {
                        width: parent.width - 300
                        height: 1
                    }

                    // View mode toggle
                    Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter

                        // List view button
                        DankActionButton {
                            buttonSize: 36
                            circular: false
                            iconName: "view_list"
                            iconSize: 20
                            iconColor: viewMode === "list" ? Theme.primary : Theme.surfaceText
                            hoverColor: viewMode === "list" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)
                            backgroundColor: viewMode === "list" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                            onClicked: {
                                viewMode = "list";
                                Prefs.setAppLauncherViewMode("list");
                            }
                        }

                        // Grid view button
                        DankActionButton {
                            buttonSize: 36
                            circular: false
                            iconName: "grid_view"
                            iconSize: 20
                            iconColor: viewMode === "grid" ? Theme.primary : Theme.surfaceText
                            hoverColor: viewMode === "grid" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08)
                            backgroundColor: viewMode === "grid" ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                            onClicked: {
                                viewMode = "grid";
                                Prefs.setAppLauncherViewMode("grid");
                            }
                        }

                    }

                }

                // App grid/list container
                Rectangle {
                    width: parent.width
                    height: {
                        // Calculate more precise remaining height
                        let usedHeight = 40 + Theme.spacingL;
                        // Header
                        usedHeight += 52 + Theme.spacingL;
                        // Search container
                        usedHeight += (searchField.text.length === 0 ? 40 + Theme.spacingL : 0);
                        // Category/controls when visible
                        return parent.height - usedHeight;
                    }
                    color: "transparent"

                    // List view
                    DankListView {
                        id: appList

                        anchors.fill: parent
                        visible: viewMode === "list"
                        model: filteredModel
                        currentIndex: selectedIndex
                        itemHeight: 72
                        iconSize: 56
                        showDescription: true
                        hoverUpdatesSelection: false
                        onItemClicked: function(index, modelData) {
                            if (modelData.desktopEntry) {
                                Prefs.addRecentApp(modelData.desktopEntry);
                                modelData.desktopEntry.execute();
                            } else {
                                launcher.launchApp(modelData.exec);
                            }
                            launcher.hide();
                        }
                        onItemHovered: function(index) {
                            selectedIndex = index;
                        }
                    }

                    // Grid view
                    DankGridView {
                        id: appGrid

                        anchors.fill: parent
                        visible: viewMode === "grid"
                        model: filteredModel
                        columns: 4
                        adaptiveColumns: false
                        currentIndex: selectedIndex
                        hoverUpdatesSelection: false
                        onItemClicked: function(index, modelData) {
                            if (modelData.desktopEntry) {
                                Prefs.addRecentApp(modelData.desktopEntry);
                                modelData.desktopEntry.execute();
                            } else {
                                launcher.launchApp(modelData.exec);
                            }
                            launcher.hide();
                        }
                        onItemHovered: function(index) {
                            selectedIndex = index;
                        }
                    }

                }

                // Category dropdown overlay - now positioned absolutely
                Rectangle {
                    id: categoryDropdown

                    width: 200
                    height: Math.min(250, categories.length * 40 + Theme.spacingM * 2)
                    radius: Theme.cornerRadiusLarge
                    color: Theme.contentBackground()
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1
                    visible: showCategories
                    z: 1000
                    // Position it below the category button
                    anchors.top: parent.top
                    anchors.topMargin: 140 + (searchField.text.length === 0 ? 0 : -40)
                    anchors.left: parent.left

                    // Drop shadow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        color: "transparent"
                        radius: parent.radius + 4
                        z: -1
                        layer.enabled: true

                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowHorizontalOffset: 0
                            shadowVerticalOffset: 0
                            shadowBlur: 0.25 // radius/32
                            shadowColor: Qt.rgba(0, 0, 0, 0.2)
                            shadowOpacity: 0.2
                        }

                    }

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        ListView {
                            // Make mouse wheel scrolling more responsive
                            property real wheelStepSize: 60

                            model: categories
                            spacing: 4

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                propagateComposedEvents: true
                                z: -1
                                onWheel: (wheel) => {
                                    var delta = wheel.angleDelta.y;
                                    var steps = delta / 120; // Standard wheel step
                                    parent.contentY -= steps * parent.wheelStepSize;
                                    // Ensure we stay within bounds
                                    if (parent.contentY < 0)
                                        parent.contentY = 0;
                                    else if (parent.contentY > parent.contentHeight - parent.height)
                                        parent.contentY = Math.max(0, parent.contentHeight - parent.height);
                                }
                            }

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 36
                                radius: Theme.cornerRadiusSmall
                                color: catArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : "transparent"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: selectedCategory === modelData ? Theme.primary : Theme.surfaceText
                                    font.weight: selectedCategory === modelData ? Font.Medium : Font.Normal
                                }

                                MouseArea {
                                    id: catArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        selectedCategory = modelData;
                                        showCategories = false;
                                        updateFilteredModel();
                                    }
                                }

                            }

                        }

                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }

        }

    }

}
