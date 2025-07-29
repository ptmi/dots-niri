import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.Common
import qs.Modules.ControlCenter.Audio
import qs.Services
import qs.Widgets

Item {
    id: audioTab

    property int audioSubTab: 0

    Column {
        anchors.fill: parent
        spacing: Theme.spacingM

        DankTabBar {
            width: parent.width
            tabHeight: 40
            currentIndex: audioTab.audioSubTab
            showIcons: false
            model: [{
                "text": "Output"
            }, {
                "text": "Input"
            }]
            onTabClicked: function(index) {
                audioTab.audioSubTab = index;
            }
        }

        ScrollView {
            width: parent.width
            height: parent.height - 48
            visible: audioTab.audioSubTab === 0
            clip: true

            Column {
                width: parent.width
                spacing: Theme.spacingL

                VolumeControl {
                }

                AudioDevicesList {
                }

            }

        }

        ScrollView {
            width: parent.width
            height: parent.height - 48
            visible: audioTab.audioSubTab === 1
            clip: true

            Column {
                width: parent.width
                spacing: Theme.spacingL

                MicrophoneControl {
                }

                AudioInputDevicesList {
                }

            }

        }

    }

}
