pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    function displayName(node) {
        if (!node) return ""
        
        if (node.properties && node.properties["device.description"]) {
            return node.properties["device.description"]
        }

        if (node.description && node.description !== node.name) {
            return node.description
        }

        if (node.nickname && node.nickname !== node.name) {
            return node.nickname
        }

        if (node.name.includes("analog-stereo")) return "Built-in Speakers"
        else if (node.name.includes("bluez")) return "Bluetooth Audio"
        else if (node.name.includes("usb")) return "USB Audio"
        else if (node.name.includes("hdmi")) return "HDMI Audio"

        return node.name
    }

    function subtitle(name) {
        if (!name) return ""

        if (name.includes('usb-')) {
            if (name.includes('SteelSeries')) {
                return "USB Gaming Headset"
            } else if (name.includes('Generic')) {
                return "USB Audio Device"
            }
            return "USB Audio"
        } else if (name.includes('pci-')) {
            if (name.includes('01_00.1') || name.includes('01:00.1')) {
                return "NVIDIA GPU Audio"
            }
            return "PCI Audio"
        } else if (name.includes('bluez')) {
            return "Bluetooth Audio"
        } else if (name.includes('analog')) {
            return "Built-in Audio"
        } else if (name.includes('hdmi')) {
            return "HDMI Audio"
        }

        return ""
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}