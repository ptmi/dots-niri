import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    property alias content: contentLoader.sourceComponent
    property alias contentLoader: contentLoader
    property real width: 400
    property real height: 300
    readonly property real screenWidth: screen ? screen.width : 1920
    readonly property real screenHeight: screen ? screen.height : 1080
    property bool showBackground: true
    property real backgroundOpacity: 0.5
    property string positioning: "center"
    property point customPosition: Qt.point(0, 0)
    property string keyboardFocus: "ondemand"
    property bool closeOnEscapeKey: true
    property bool closeOnBackgroundClick: true
    property string animationType: "scale"
    property int animationDuration: Theme.mediumDuration
    property var animationEasing: Theme.emphasizedEasing
    property color backgroundColor: Theme.surfaceContainer
    property color borderColor: Theme.outlineMedium
    property real borderWidth: 1
    property real cornerRadius: Theme.cornerRadius
    property bool enableShadow: false
    // Expose the focusScope for external access
    property alias modalFocusScope: focusScope

    signal opened()
    signal dialogClosed()
    signal backgroundClicked()

    function open() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    function toggle() {
        visible = !visible;
    }

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

    Rectangle {
        id: contentContainer

        width: root.width
        height: root.height
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
        opacity: root.visible ? 1 : 0
        scale: {
            if (root.animationType === "scale")
                return root.visible ? 1 : 0.9;

            return 1;
        }
        transform: root.animationType === "slide" ? slideTransform : null

        Translate {
            id: slideTransform

            x: root.visible ? 0 : 15
            y: root.visible ? 0 : -30
        }

        Loader {
            id: contentLoader

            anchors.fill: parent
            active: root.visible
            asynchronous: false
        }

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

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
            shadowBlur: 1
            shadowColor: Theme.shadowStrong
            shadowOpacity: 0.3
        }

    }

    FocusScope {
        id: focusScope

        objectName: "modalFocusScope"
        anchors.fill: parent
        visible: root.visible // Only active when the modal is visible
        focus: root.visible
        Keys.onEscapePressed: (event) => {
            if (root.closeOnEscapeKey) {
                root.visible = false;
                event.accepted = true;
            }
        }
        onVisibleChanged: {
            if (visible)
                Qt.callLater(function() {
                focusScope.forceActiveFocus();
            });

        }
    }

}
