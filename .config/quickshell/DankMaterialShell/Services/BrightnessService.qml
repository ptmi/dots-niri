import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
pragma Singleton
pragma ComponentBehavior

Singleton {
    id: root

    property bool brightnessAvailable: devices.length > 0
    property var devices: []
    property var deviceBrightness: ({})
    property string currentDevice: ""
    property string lastIpcDevice: ""
    property int brightnessLevel: {
        const deviceToUse = lastIpcDevice === "" ? getDefaultDevice() : (lastIpcDevice || currentDevice);
        return deviceToUse ? (deviceBrightness[deviceToUse] || 50) : 50;
    }
    property int maxBrightness: 100
    property bool brightnessInitialized: false

    signal brightnessChanged()
    signal deviceSwitched()
    
    property bool nightModeActive: false

    function setBrightnessInternal(percentage, device) {
        const clampedValue = Math.max(1, Math.min(100, percentage));
        const actualDevice = device === "" ? getDefaultDevice() : (device || currentDevice || getDefaultDevice());
        
        // Update the device brightness cache
        if (actualDevice) {
            var newBrightness = deviceBrightness;
            newBrightness[actualDevice] = clampedValue;
            deviceBrightness = newBrightness;
        }
        
        if (device)
            brightnessSetProcess.command = ["brightnessctl", "-d", device, "set", clampedValue + "%"];
        else
            brightnessSetProcess.command = ["brightnessctl", "set", clampedValue + "%"];
        brightnessSetProcess.running = true;
    }

    function setBrightness(percentage, device) {
        setBrightnessInternal(percentage, device);
        brightnessChanged();
    }

    function setCurrentDevice(deviceName) {
        if (currentDevice === deviceName)
            return ;

        currentDevice = deviceName;
        lastIpcDevice = deviceName;
        deviceSwitched();
        brightnessGetProcess.command = ["brightnessctl", "-m", "-d", deviceName, "get"];
        brightnessGetProcess.running = true;
    }

    function refreshDevices() {
        deviceListProcess.running = true;
    }

    function getDeviceBrightness(deviceName) {
        return deviceBrightness[deviceName] || 50;
    }

    function getDefaultDevice() {
        // Find first backlight device
        for (const device of devices) {
            if (device.class === "backlight") {
                return device.name;
            }
        }
        // Fallback to first device if no backlight found
        return devices.length > 0 ? devices[0].name : "";
    }

    function getCurrentDeviceInfo() {
        const deviceToUse = lastIpcDevice === "" ? getDefaultDevice() : (lastIpcDevice || currentDevice);
        if (!deviceToUse) return null;
        
        for (const device of devices) {
            if (device.name === deviceToUse) {
                return device;
            }
        }
        return null;
    }
    
    function enableNightMode() {
        if (nightModeActive) return;
        
        // Test if gammastep exists before enabling
        gammaStepTestProcess.running = true;
    }
    
    function updateNightModeTemperature(temperature) {
        SessionData.setNightModeTemperature(temperature);
        
        // If night mode is active, restart it with new temperature
        if (nightModeActive) {
            // Temporarily disable and re-enable to restart with new temp
            nightModeActive = false;
            Qt.callLater(() => {
                if (SessionData.nightModeEnabled) {
                    nightModeActive = true;
                }
            });
        }
    }
    
    function disableNightMode() {
        nightModeActive = false;
        SessionData.setNightModeEnabled(false);
        
        // Also kill any stray gammastep processes
        Quickshell.execDetached(["pkill", "gammastep"]);
    }
    
    function toggleNightMode() {
        if (nightModeActive) {
            disableNightMode();
        } else {
            enableNightMode();
        }
    }

    Component.onCompleted: {
        refreshDevices();
        
        // Check if night mode was enabled on startup
        if (SessionData.nightModeEnabled) {
            enableNightMode();
        }
    }

    Process {
        id: deviceListProcess

        command: ["brightnessctl", "-m", "-l"]
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                console.warn("BrightnessService: Failed to list devices:", exitCode);
                brightnessAvailable = false;
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) {
                    console.warn("BrightnessService: No devices found");
                    return ;
                }
                const lines = text.trim().split("\n");
                const newDevices = [];
                for (const line of lines) {
                    const parts = line.split(",");
                    if (parts.length >= 5)
                        newDevices.push({
                        "name": parts[0],
                        "class": parts[1],
                        "current": parseInt(parts[2]),
                        "percentage": parseInt(parts[3]),
                        "max": parseInt(parts[4])
                    });

                }
                newDevices.sort((a, b) => {
                    if (a.class === "backlight" && b.class !== "backlight")
                        return -1;

                    if (a.class !== "backlight" && b.class === "backlight")
                        return 1;

                    return a.name.localeCompare(b.name);
                });
                devices = newDevices;
                if (devices.length > 0 && !currentDevice)
                    setCurrentDevice(devices[0].name);

            }
        }

    }

    Process {
        id: brightnessSetProcess

        running: false
        onExited: function(exitCode) {
            if (exitCode !== 0)
                console.warn("BrightnessService: Failed to set brightness:", exitCode);

        }
    }

    Process {
        id: brightnessGetProcess

        running: false
        onExited: function(exitCode) {
            if (exitCode !== 0)
                console.warn("BrightnessService: Failed to get brightness:", exitCode);

        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return ;

                const parts = text.trim().split(",");
                if (parts.length >= 5) {
                    const current = parseInt(parts[2]);
                    const max = parseInt(parts[4]);
                    maxBrightness = max;
                    const brightness = Math.round((current / max) * 100);
                    
                    // Update the device brightness cache
                    if (currentDevice) {
                        var newBrightness = deviceBrightness;
                        newBrightness[currentDevice] = brightness;
                        deviceBrightness = newBrightness;
                    }
                    
                    brightnessInitialized = true;
                    console.log("BrightnessService: Device", currentDevice, "brightness:", brightness + "%");
                    brightnessChanged();
                }
            }
        }

    }

    Process {
        id: gammaStepTestProcess
        
        command: ["which", "gammastep"]
        running: false
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                // gammastep exists, enable night mode
                nightModeActive = true;
                SessionData.setNightModeEnabled(true);
            } else {
                // gammastep not found
                console.warn("BrightnessService: gammastep not found");
                ToastService.showWarning("Night mode failed: gammastep not found");
            }
        }
    }
    
    Process {
        id: gammaStepProcess
        
        command: {
            const temperature = SessionData.nightModeTemperature || 4500;
            return ["gammastep", "-m", "wayland", "-O", String(temperature)];
        }
        running: nightModeActive
        
        onExited: function(exitCode) {
            // If process exits with non-zero code while we think it should be running
            if (nightModeActive && exitCode !== 0) {
                console.warn("BrightnessService: Night mode process crashed with exit code:", exitCode);
                nightModeActive = false;
                SessionData.setNightModeEnabled(false);
                ToastService.showWarning("Night mode failed: process crashed");
            }
        }
    }
    
    // IPC Handler for external control
    IpcHandler {
        function set(percentage: string, device: string) : string {
            if (!root.brightnessAvailable)
                return "Brightness control not available";

            const value = parseInt(percentage);
            const clampedValue = Math.max(1, Math.min(100, value));
            const targetDevice = device || "";
            root.lastIpcDevice = targetDevice;
            if (targetDevice && targetDevice !== root.currentDevice) {
                root.setCurrentDevice(targetDevice);
            }
            root.setBrightness(clampedValue, targetDevice);
            if (targetDevice)
                return "Brightness set to " + clampedValue + "% on " + targetDevice;
            else
                return "Brightness set to " + clampedValue + "%";
        }

        function increment(step: string, device: string) : string {
            if (!root.brightnessAvailable)
                return "Brightness control not available";

            const targetDevice = device || "";
            const actualDevice = targetDevice === "" ? root.getDefaultDevice() : targetDevice;
            const currentLevel = actualDevice ? root.getDeviceBrightness(actualDevice) : root.brightnessLevel;
            const stepValue = parseInt(step || "10");
            const newLevel = Math.max(1, Math.min(100, currentLevel + stepValue));
            root.lastIpcDevice = targetDevice;
            if (targetDevice && targetDevice !== root.currentDevice) {
                root.setCurrentDevice(targetDevice);
            }
            root.setBrightness(newLevel, targetDevice);
            if (targetDevice)
                return "Brightness increased to " + newLevel + "% on " + targetDevice;
            else
                return "Brightness increased to " + newLevel + "%";
        }

        function decrement(step: string, device: string) : string {
            if (!root.brightnessAvailable)
                return "Brightness control not available";

            const targetDevice = device || "";
            const actualDevice = targetDevice === "" ? root.getDefaultDevice() : targetDevice;
            const currentLevel = actualDevice ? root.getDeviceBrightness(actualDevice) : root.brightnessLevel;
            const stepValue = parseInt(step || "10");
            const newLevel = Math.max(1, Math.min(100, currentLevel - stepValue));
            root.lastIpcDevice = targetDevice;
            if (targetDevice && targetDevice !== root.currentDevice) {
                root.setCurrentDevice(targetDevice);
            }
            root.setBrightness(newLevel, targetDevice);
            if (targetDevice)
                return "Brightness decreased to " + newLevel + "% on " + targetDevice;
            else
                return "Brightness decreased to " + newLevel + "%";
        }

        function status() : string {
            if (!root.brightnessAvailable)
                return "Brightness control not available";

            return "Device: " + root.currentDevice + " - Brightness: " + root.brightnessLevel + "%";
        }

        function list() : string {
            if (!root.brightnessAvailable)
                return "No brightness devices available";

            let result = "Available devices:\n";
            for (const device of root.devices) {
                result += device.name + " (" + device.class + ")\n";
            }
            return result;
        }

        target: "brightness"
    }
    
    // IPC Handler for night mode control
    IpcHandler {
        function toggle() : string {
            root.toggleNightMode();
            return root.nightModeActive ? "Night mode enabled" : "Night mode disabled";
        }
        
        function enable() : string {
            root.enableNightMode();
            return "Night mode enabled";
        }
        
        function disable() : string {
            root.disableNightMode();
            return "Night mode disabled";
        }
        
        function status() : string {
            return root.nightModeActive ? "Night mode is enabled" : "Night mode is disabled";
        }
        
        function temperature(value: string) : string {
            if (!value) {
                return "Current temperature: " + SessionData.nightModeTemperature + "K";
            }
            
            const temp = parseInt(value);
            if (isNaN(temp)) {
                return "Invalid temperature. Use a value between 2500 and 6000 (in steps of 500)";
            }
            
            // Validate temperature is in valid range and steps
            if (temp < 2500 || temp > 6000) {
                return "Temperature must be between 2500K and 6000K";
            }
            
            // Round to nearest 500
            const rounded = Math.round(temp / 500) * 500;
            
            SessionData.setNightModeTemperature(rounded);
            
            // If night mode is active, restart it with new temperature
            if (root.nightModeActive) {
                root.nightModeActive = false;
                Qt.callLater(() => {
                    root.nightModeActive = true;
                });
            }
            
            if (rounded !== temp) {
                return "Night mode temperature set to " + rounded + "K (rounded from " + temp + "K)";
            } else {
                return "Night mode temperature set to " + rounded + "K";
            }
        }
        
        target: "night"
    }

}
