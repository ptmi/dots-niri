import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

DankModal {
    // Don't hide the interface, just show toast

    id: clipboardHistoryModal

    property bool isVisible: false
    property int totalCount: 0
    property var activeTheme: Theme
    property bool showClearConfirmation: false
    property var clipboardEntries: []
    property string searchText: ""

    function updateFilteredModel() {
        filteredClipboardModel.clear();
        for (let i = 0; i < clipboardModel.count; i++) {
            const entry = clipboardModel.get(i).entry;
            if (searchText.trim().length === 0) {
                filteredClipboardModel.append({
                    "entry": entry
                });
            } else {
                const content = getEntryPreview(entry).toLowerCase();
                if (content.includes(searchText.toLowerCase()))
                    filteredClipboardModel.append({
                    "entry": entry
                });

            }
        }
        clipboardHistoryModal.totalCount = filteredClipboardModel.count;
    }

    function toggle() {
        if (isVisible)
            hide();
        else
            show();
    }

    function show() {
        clipboardHistoryModal.isVisible = true;
        refreshClipboard();
        console.log("ClipboardHistoryModal: Opening and refreshing");
    }

    function hide() {
        clipboardHistoryModal.isVisible = false;
        clipboardHistoryModal.searchText = "";
        cleanupTempFiles();
    }

    function cleanupTempFiles() {
        cleanupProcess.command = ["sh", "-c", "rm -f /tmp/clipboard_preview_*.png"];
        cleanupProcess.running = true;
    }

    function refreshClipboard() {
        clipboardProcess.running = true;
    }

    function copyEntry(entry) {
        const entryId = entry.split('\t')[0];
        copyProcess.command = ["sh", "-c", `cliphist decode ${entryId} | wl-copy`];
        copyProcess.running = true;
        console.log("ClipboardHistoryModal: Entry copied, showing toast");
        ToastService.showInfo("Copied to clipboard");
    }

    function deleteEntry(entry) {
        console.log("Deleting entry:", entry);
        deleteProcess.command = ["sh", "-c", `echo '${entry.replace(/'/g, "'\\''")}' | cliphist delete`];
        deleteProcess.running = true;
    }

    function clearAll() {
        clearProcess.running = true;
    }

    function getEntryPreview(entry) {
        let content = entry.replace(/^\s*\d+\s+/, "");
        if (content.includes("image/") || content.includes("binary data") || /\.(png|jpg|jpeg|gif|bmp|webp)/i.test(content)) {
            const dimensionMatch = content.match(/(\d+)x(\d+)/);
            if (dimensionMatch)
                return `Image ${dimensionMatch[1]}×${dimensionMatch[2]}`;

            const typeMatch = content.match(/\b(png|jpg|jpeg|gif|bmp|webp)\b/i);
            if (typeMatch)
                return `Image (${typeMatch[1].toUpperCase()})`;

            return "Image";
        }
        if (content.length > 100)
            return content.substring(0, 100) + "...";

        return content;
    }

    function getEntryType(entry) {
        if (entry.includes("image/") || entry.includes("binary data") || /\.(png|jpg|jpeg|gif|bmp|webp)/i.test(entry) || /\b(png|jpg|jpeg|gif|bmp|webp)\b/i.test(entry))
            return "image";

        if (entry.length > 200)
            return "long_text";

        return "text";
    }

    // DankModal configuration
    visible: isVisible
    width: 650
    height: 550
    keyboardFocus: "ondemand"
    onBackgroundClicked: {
        hide();
    }

    // Clear confirmation dialog
    DankModal {
        id: clearConfirmDialog

        visible: showClearConfirmation
        width: 350
        height: 150
        keyboardFocus: "ondemand"
        onBackgroundClicked: {
            showClearConfirmation = false;
        }

        content: Component {
            Item {
                anchors.fill: parent

                Column {
                    anchors.centerIn: parent
                    width: parent.width - Theme.spacingM * 2
                    spacing: Theme.spacingM

                    Text {
                        text: "Clear All History?"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "This will permanently delete all clipboard history."
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.spacingM

                        Rectangle {
                            width: 100
                            height: 40
                            radius: Theme.cornerRadius
                            color: cancelClearButton.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.12) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                            Text {
                                text: "Cancel"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: cancelClearButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: showClearConfirmation = false
                            }

                        }

                        Rectangle {
                            width: 100
                            height: 40
                            radius: Theme.cornerRadius
                            color: confirmClearButton.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.9) : Theme.error

                            Text {
                                text: "Clear All"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.primaryText
                                font.weight: Font.Medium
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: confirmClearButton

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    clearAll();
                                    showClearConfirmation = false;
                                    hide();
                                }
                            }

                        }

                    }

                }

            }

        }

    }

    // Data models
    ListModel {
        id: clipboardModel
    }

    ListModel {
        id: filteredClipboardModel
    }

    // Processes
    Process {
        id: clipboardProcess

        command: ["cliphist", "list"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                clipboardModel.clear();
                const lines = text.trim().split('\n');
                for (const line of lines) {
                    if (line.trim().length > 0)
                        clipboardModel.append({
                            "entry": line
                        });

                }
                updateFilteredModel();
            }
        }

    }

    Process {
        id: copyProcess

        running: false
        onExited: (exitCode) => {
            if (exitCode !== 0)
                console.error("Copy failed with exit code:", exitCode);

        }
    }

    Process {
        id: deleteProcess

        running: false
        onExited: (exitCode) => {
            if (exitCode === 0)
                refreshClipboard();
            else
                console.error("Delete failed with exit code:", exitCode);
        }
    }

    Process {
        id: clearProcess

        command: ["cliphist", "wipe"]
        running: false
        onExited: (exitCode) => {
            if (exitCode === 0) {
                clipboardModel.clear();
                filteredClipboardModel.clear();
                totalCount = 0;
            } else {
                console.error("Clear failed with exit code:", exitCode);
            }
        }
    }

    Process {
        id: cleanupProcess

        running: false
    }

    IpcHandler {
        function open() {
            console.log("ClipboardHistoryModal: IPC open() called");
            clipboardHistoryModal.show();
            return "CLIPBOARD_OPEN_SUCCESS";
        }

        function close() {
            console.log("ClipboardHistoryModal: IPC close() called");
            clipboardHistoryModal.hide();
            return "CLIPBOARD_CLOSE_SUCCESS";
        }

        function toggle() {
            console.log("ClipboardHistoryModal: IPC toggle() called");
            clipboardHistoryModal.toggle();
            return "CLIPBOARD_TOGGLE_SUCCESS";
        }

        target: "clipboard"
    }

    content: Component {
        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            // Header with search
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "content_paste"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: `Clipboard History (${totalCount})`
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankActionButton {
                        iconName: "delete_sweep"
                        iconSize: Theme.iconSize
                        iconColor: Theme.error
                        hoverColor: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                        onClicked: {
                            showClearConfirmation = true;
                        }
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        hoverColor: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                        onClicked: hide()
                    }

                }

            }

            // Search field
            DankTextField {
                id: searchField

                width: parent.width
                placeholderText: "Search clipboard history..."
                leftIconName: "search"
                showClearButton: true
                onTextChanged: {
                    clipboardHistoryModal.searchText = text;
                    updateFilteredModel();
                }

                Connections {
                    function onOpened() {
                        searchField.forceActiveFocus();
                    }

                    function onDialogClosed() {
                        searchField.clearFocus();
                    }

                    target: clipboardHistoryModal
                }

            }

            // Clipboard entries list
            Rectangle {
                width: parent.width
                height: parent.height - 110
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingS
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ListView {
                        id: clipboardListView

                        width: parent.availableWidth
                        model: filteredClipboardModel
                        spacing: Theme.spacingXS

                        Text {
                            text: "No clipboard entries found"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            visible: filteredClipboardModel.count === 0
                        }

                        delegate: Rectangle {
                            property string entryType: getEntryType(model.entry)
                            property string entryPreview: getEntryPreview(model.entry)
                            property int entryIndex: index + 1

                            width: clipboardListView.width
                            height: Math.max(60, contentText.contentHeight + Theme.spacingL)
                            radius: Theme.cornerRadius
                            color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.04)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                anchors.rightMargin: Theme.spacingS // Reduced right margin
                                spacing: Theme.spacingL

                                // Index number
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: entryIndex.toString()
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.Bold
                                        color: Theme.primary
                                    }

                                }

                                // Content icon and text
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 68 // Account for index (24) + spacing (16) + delete button (32) - small margin
                                    spacing: Theme.spacingM

                                    DankIcon {
                                        name: {
                                            if (entryType === "image")
                                                return "image";

                                            if (entryType === "long_text")
                                                return "subject";

                                            return "content_copy";
                                        }
                                        size: Theme.iconSize
                                        color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - Theme.iconSize - Theme.spacingM
                                        spacing: Theme.spacingXS

                                        Text {
                                            text: {
                                                switch (entryType) {
                                                case "image":
                                                    return "Image • " + entryPreview;
                                                case "long_text":
                                                    return "Long Text";
                                                default:
                                                    return "Text";
                                                }
                                            }
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.primary
                                            font.weight: Font.Medium
                                            width: parent.width
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            id: contentText

                                            text: entryPreview
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            width: parent.width
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: entryType === "long_text" ? 3 : 1
                                            elide: Text.ElideRight
                                        }

                                    }

                                }

                            }

                            // Delete button
                            DankActionButton {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.spacingM
                                anchors.verticalCenter: parent.verticalCenter
                                iconName: "dangerous"
                                iconSize: Theme.iconSize - 4
                                iconColor: Theme.error
                                hoverColor: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
                                onClicked: {
                                    console.log("Delete clicked for entry:", model.entry);
                                    deleteEntry(model.entry);
                                }
                            }

                            // Main click area - explicitly excludes delete button area
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                anchors.rightMargin: 40 // Enough space to avoid delete button (32 + 8 margin)
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: copyEntry(model.entry)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                }
                            }

                        }

                    }

                }

            }

        }

    }

}
