import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

PanelWindow {
    id: root

    // Core properties
    property alias content: contentLoader.sourceComponent
    // Sizing - can use fixed or relative to screen
    property real width: 400
    property real height: 300
    // Screen-relative sizing helpers
    readonly property real screenWidth: screen ? screen.width : 1920
    readonly property real screenHeight: screen ? screen.height : 1080
    // Background behavior
    property bool showBackground: true
    property real backgroundOpacity: 0.5
    // Positioning
    property string positioning: "center"
    // "center", "top-right", "custom"
    property point customPosition: Qt.point(0, 0)
    // Focus management
    property string keyboardFocus: "ondemand"
    // "ondemand", "exclusive", "none"
    property bool closeOnEscapeKey: true
    property bool closeOnBackgroundClick: true
    // Animation
    property string animationType: "scale"
    // "scale", "slide", "fade"
    property int animationDuration: Theme.mediumDuration
    property var animationEasing: Theme.emphasizedEasing
    // Styling
    property color backgroundColor: Theme.surfaceContainer
    property color borderColor: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    property real borderWidth: 1
    property real cornerRadius: Theme.cornerRadiusLarge
    property bool enableShadow: false

    // Signals
    signal opened()
    signal dialogClosed()
    signal backgroundClicked()

    // Convenience functions
    function open() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    function toggle() {
        visible = !visible;
    }

    // PanelWindow configuration
    // visible property is inherited from PanelWindow
    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: {
        switch (root.keyboardFocus) {
        case "exclusive":
            return WlrKeyboardFocus.Exclusive;
        case "none":
            return WlrKeyboardFocus.None;
        default:
            return WlrKeyboardFocus.OnDemand;
        }
    }
    onVisibleChanged: {
        if (root.visible) {
            opened();
        } else {
            // Properly cleanup text input surfaces
            if (Qt.inputMethod) {
                Qt.inputMethod.hide();
                Qt.inputMethod.reset();
            }
            dialogClosed();
        }
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Background overlay
    Rectangle {
        id: background

        anchors.fill: parent
        color: "black"
        opacity: root.showBackground ? (root.visible ? root.backgroundOpacity : 0) : 0
        visible: root.showBackground

        MouseArea {
            anchors.fill: parent
            enabled: root.closeOnBackgroundClick
            onClicked: (mouse) => {
                var localPos = mapToItem(contentContainer, mouse.x, mouse.y);
                if (localPos.x < 0 || localPos.x > contentContainer.width || localPos.y < 0 || localPos.y > contentContainer.height)
                    root.backgroundClicked();

            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: root.animationEasing
            }

        }

    }

    // Main content container
    Rectangle {
        id: contentContainer

        width: root.width
        height: root.height
        // Positioning
        anchors.centerIn: positioning === "center" ? parent : undefined
        x: {
            if (positioning === "top-right")
                return Math.max(Theme.spacingL, root.screenWidth - width - Theme.spacingL);
            else if (positioning === "custom")
                return root.customPosition.x;
            return 0; // Will be overridden by anchors.centerIn when positioning === "center"
        }
        y: {
            if (positioning === "top-right")
                return Theme.barHeight + Theme.spacingXS;
            else if (positioning === "custom")
                return root.customPosition.y;
            return 0; // Will be overridden by anchors.centerIn when positioning === "center"
        }
        color: root.backgroundColor
        radius: root.cornerRadius
        border.color: root.borderColor
        border.width: root.borderWidth
        layer.enabled: root.enableShadow
        // Animation properties
        opacity: root.visible ? 1 : 0
        scale: {
            if (root.animationType === "scale")
                return root.visible ? 1 : 0.9;

            return 1;
        }
        // Transform for slide animation
        transform: root.animationType === "slide" ? slideTransform : null

        Translate {
            id: slideTransform

            x: root.visible ? 0 : 15
            y: root.visible ? 0 : -30
        }

        // Content area
        Loader {
            id: contentLoader

            anchors.fill: parent
            active: true
            asynchronous: false
        }

        // Animations
        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: root.animationEasing
            }

        }

        Behavior on scale {
            enabled: root.animationType === "scale"

            NumberAnimation {
                duration: root.animationDuration
                easing.type: root.animationEasing
            }

        }

        // Shadow effect
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
            shadowBlur: 1
            shadowColor: Qt.rgba(0, 0, 0, 0.3)
            shadowOpacity: 0.3
        }

    }

    // Keyboard handling
    FocusScope {
        id: focusScope

        anchors.fill: parent
        visible: root.visible // Only active when the modal is visible
        Keys.onEscapePressed: (event) => {
            if (root.closeOnEscapeKey) {
                root.visible = false;
                event.accepted = true;
            }
        }
    }

}
