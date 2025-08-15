pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property bool brightnessAvailable: laptopBacklightAvailable || ddcAvailable
    property bool laptopBacklightAvailable: false
    property bool ddcAvailable: false
    property int brightnessLevel: 75
    property int maxBrightness: 100
    property int currentRawBrightness: 0
    
    function setBrightness(percentage) {
        brightnessLevel = Math.max(1, Math.min(100, percentage));
        
        if (laptopBacklightAvailable) {
            laptopBrightnessProcess.command = ["brightnessctl", "set", brightnessLevel + "%"];
            laptopBrightnessProcess.running = true;
        } else if (ddcAvailable) {
            console.log("Setting DDC brightness to:", brightnessLevel);
            Quickshell.execDetached(["ddcutil", "setvcp", "10", brightnessLevel.toString()]);
        }
    }
    
    function increaseBrightness() {
        setBrightness(brightnessLevel + 10);
    }
    
    function decreaseBrightness() {
        setBrightness(brightnessLevel - 10);
    }
    
    Component.onCompleted: {
        ddcAvailabilityChecker.running = true;
        laptopBacklightChecker.running = true;
    }
    
    onLaptopBacklightAvailableChanged: {
        if (laptopBacklightAvailable) {
            laptopBrightnessInitProcess.running = true;
        }
    }
    
    onDdcAvailableChanged: {
        if (ddcAvailable) {
            ddcBrightnessInitProcess.running = true;
        }
    }
    
    Process {
        id: ddcAvailabilityChecker
        command: ["which", "ddcutil"]
        onExited: function(exitCode) {
            ddcAvailable = (exitCode === 0);
        }
    }
    
    Process {
        id: laptopBacklightChecker
        command: ["brightnessctl", "--list"]
        onExited: function(exitCode) {
            laptopBacklightAvailable = (exitCode === 0);
        }
    }
    
    Process {
        id: laptopBrightnessProcess
        running: false
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                console.warn("Failed to set laptop brightness, exit code:", exitCode);
            }
        }
    }
    
    Process {
        id: laptopBrightnessInitProcess
        command: ["brightnessctl", "get"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    currentRawBrightness = parseInt(text.trim());
                    laptopMaxBrightnessProcess.running = true;
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                console.warn("Failed to get laptop brightness, exit code:", exitCode);
            }
        }
    }
    
    Process {
        id: laptopMaxBrightnessProcess
        command: ["brightnessctl", "max"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    maxBrightness = parseInt(text.trim());
                    brightnessLevel = Math.round((currentRawBrightness / maxBrightness) * 100);
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                console.warn("Failed to get max laptop brightness, exit code:", exitCode);
            }
        }
    }
    
    Process {
        id: ddcBrightnessInitProcess
        command: ["ddcutil", "getvcp", "10", "--brief"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    const parts = text.trim().split(" ");
                    if (parts.length >= 5) {
                        const current = parseInt(parts[3]) || 75;
                        const max = parseInt(parts[4]) || 100;
                        brightnessLevel = Math.round((current / max) * 100);
                    }
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                console.warn("Failed to get DDC brightness, exit code:", exitCode);
                brightnessLevel = 75;
            }
        }
    }
}