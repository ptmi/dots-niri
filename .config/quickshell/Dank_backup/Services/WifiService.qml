pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWifiSSID: ""
    property string wifiSignalStrength: "excellent" // "excellent", "good", "fair", "poor"
    property var wifiNetworks: []
    property var savedWifiNetworks: []
    property bool isScanning: false
    property string connectionStatus: "" // "connecting", "connected", "failed", "invalid_password", ""
    property string connectingSSID: ""
    property string lastConnectionError: ""
    property bool passwordDialogShouldReopen: false
    // Auto-refresh timer for when control center is open
    property bool autoRefreshEnabled: false
    
    signal networksUpdated()
    
    // Network info properties
    property string networkInfoSSID: ""
    property string networkInfoDetails: ""
    property bool networkInfoLoading: false

    function scanWifi() {
        if (root.isScanning)
            return ;

        root.isScanning = true;
        wifiScanner.running = true;
        savedWifiScanner.running = true;
        currentWifiInfo.running = true;
        fallbackTimer.start();
    }

    function connectToWifi(ssid) {
        console.log("Connecting to WiFi:", ssid);
        root.connectionStatus = "connecting";
        root.connectingSSID = ssid;
        ToastService.showInfo("Connecting to " + ssid + "...");
        wifiConnector.running = true;
    }

    property string wifiPassword: ""
    
    function connectToWifiWithPassword(ssid, password) {
        console.log("Connecting to WiFi with password:", ssid);
        root.connectionStatus = "connecting";
        root.connectingSSID = ssid;
        root.wifiPassword = password;
        root.lastConnectionError = "";
        root.passwordDialogShouldReopen = false;
        ToastService.showInfo("Connecting to " + ssid + "...");
        wifiPasswordConnector.running = true;
    }

    function disconnectWifi() {
        console.log("Disconnecting from current WiFi network");
        wifiDisconnector.running = true;
    }

    property string forgetSSID: ""
    
    function forgetWifiNetwork(ssid) {
        console.log("Forgetting WiFi network:", ssid);
        root.forgetSSID = ssid;
        wifiForget.running = true;
    }

    function fetchNetworkInfo(ssid) {
        console.log("Fetching network info for:", ssid);
        root.networkInfoSSID = ssid;
        root.networkInfoLoading = true;
        root.networkInfoDetails = "Loading network information...";
        wifiInfoFetcher.running = true;
    }

    function updateCurrentWifiInfo() {
        currentWifiInfo.running = true;
    }


    Process {
        id: currentWifiInfo

        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' | head -1"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (data.trim()) {
                    let parts = data.split(":");
                    if (parts.length >= 3 && parts[1].trim() !== "") {
                        root.currentWifiSSID = parts[1].trim();
                        let signal = parseInt(parts[2]) || 100;
                        if (signal >= 75)
                            root.wifiSignalStrength = "excellent";
                        else if (signal >= 50)
                            root.wifiSignalStrength = "good";
                        else if (signal >= 25)
                            root.wifiSignalStrength = "fair";
                        else
                            root.wifiSignalStrength = "poor";
                        console.log("Active WiFi:", root.currentWifiSSID, "Signal:", signal + "%");
                    }
                }
            }
        }

    }

    Process {
        id: wifiScanner

        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    let networks = [];
                    let lines = text.trim().split('\n');
                    for (let line of lines) {
                        let parts = line.split(':');
                        if (parts.length >= 3 && parts[0].trim() !== "") {
                            let ssid = parts[0].trim();
                            let signal = parseInt(parts[1]) || 0;
                            let security = parts[2].trim();
                            // Skip duplicates
                            if (!networks.find((n) => {
                                return n.ssid === ssid;
                            })) {
                                // Check if this network is saved
                                let isSaved = root.savedWifiNetworks.some((saved) => {
                                    return saved.ssid === ssid;
                                });
                                networks.push({
                                    "ssid": ssid,
                                    "signal": signal,
                                    "secured": security !== "",
                                    "connected": ssid === root.currentWifiSSID,
                                    "saved": isSaved,
                                    "signalStrength": signal >= 75 ? "excellent" : signal >= 50 ? "good" : signal >= 25 ? "fair" : "poor"
                                });
                            }
                        }
                    }
                    // Sort by signal strength
                    networks.sort((a, b) => {
                        return b.signal - a.signal;
                    });
                    root.wifiNetworks = networks;
                    console.log("Found", networks.length, "WiFi networks");
                    // Stop scanning once we have results
                    if (networks.length > 0) {
                        root.isScanning = false;
                        fallbackTimer.stop();
                    }
                }
            }
        }

    }

    Process {
        id: savedWifiScanner

        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    let saved = [];
                    let lines = text.trim().split('\n');
                    for (let line of lines) {
                        let connectionName = line.trim();
                        if (connectionName && !connectionName.includes("ethernet") && !connectionName.includes("lo") && !connectionName.includes("Wired") && !connectionName.toLowerCase().includes("eth"))
                            saved.push({
                            "ssid": connectionName,
                            "saved": true
                        });

                    }
                    root.savedWifiNetworks = saved;
                    console.log("Found", saved.length, "saved WiFi networks");
                }
            }
        }

    }


    Timer {
        id: fallbackTimer

        interval: 5000
        onTriggered: {
            root.isScanning = false;
        }
    }

    Timer {
        id: statusResetTimer

        interval: 3000
        onTriggered: {
            root.connectionStatus = "";
            root.connectingSSID = "";
        }
    }

    Timer {
        id: autoRefreshTimer

        interval: 20000
        running: root.autoRefreshEnabled
        repeat: true
        onTriggered: root.scanWifi()
    }

    // WiFi Connection Process
    Process {
        id: wifiConnector
        command: ["bash", "-c", "timeout 30 nmcli dev wifi connect \"" + root.connectingSSID + "\" || nmcli connection up \"" + root.connectingSSID + "\"; exit_code=$?; echo \"nmcli exit code: $exit_code\" >&2; if [ $exit_code -eq 0 ]; then nmcli connection modify \"" + root.connectingSSID + "\" connection.autoconnect-priority 50; sleep 2; if nmcli -t -f ACTIVE,SSID dev wifi | grep -q \"^yes:" + root.connectingSSID + "\"; then echo \"Connection verified\" >&2; exit 0; else echo \"Connection failed verification\" >&2; exit 4; fi; else exit $exit_code; fi"]
        running: false
        
        stderr: StdioCollector {
            onStreamFinished: {
                console.log("WiFi connection debug output:", text.trim())
            }
        }
        
        onExited: (exitCode) => {
            console.log("WiFi connection result:", exitCode)
            if (exitCode === 0) {
                root.connectionStatus = "connected"
                root.passwordDialogShouldReopen = false
                console.log("Connected to WiFi successfully")
                ToastService.showInfo("Connected to " + root.connectingSSID)
                NetworkService.setNetworkPreference("wifi")
                NetworkService.delayedRefreshNetworkStatus()
                
                // Immediately update savedWifiNetworks to include the new connection
                if (!root.savedWifiNetworks.some((saved) => saved.ssid === root.connectingSSID)) {
                    let updatedSaved = [...root.savedWifiNetworks];
                    updatedSaved.push({"ssid": root.connectingSSID, "saved": true});
                    root.savedWifiNetworks = updatedSaved;
                }
                
                // Update wifiNetworks to reflect the change
                let updatedNetworks = [...root.wifiNetworks];
                for (let i = 0; i < updatedNetworks.length; i++) {
                    if (updatedNetworks[i].ssid === root.connectingSSID) {
                        updatedNetworks[i].saved = true;
                        updatedNetworks[i].connected = true;
                        break;
                    }
                }
                root.wifiNetworks = updatedNetworks;
            } else if (exitCode === 4) {
                // Connection failed - likely needs password for saved network
                root.connectionStatus = "invalid_password"
                root.passwordDialogShouldReopen = true
                console.log("Saved network connection failed - password required")
                ToastService.showError("Authentication failed for " + root.connectingSSID)
            } else {
                root.connectionStatus = "failed"
                console.log("WiFi connection failed")
                ToastService.showError("Failed to connect to " + root.connectingSSID)
            }
            scanWifi()
            statusResetTimer.start()
        }

    }

    // WiFi Connection with Password Process
    Process {
        id: wifiPasswordConnector
        command: ["bash", "-c", "nmcli connection delete \"" + root.connectingSSID + "\" 2>/dev/null || true; timeout 30 nmcli dev wifi connect \"" + root.connectingSSID + "\" password \"" + root.wifiPassword + "\"; exit_code=$?; echo \"nmcli exit code: $exit_code\" >&2; if [ $exit_code -eq 0 ]; then nmcli connection modify \"" + root.connectingSSID + "\" connection.autoconnect-priority 50; sleep 2; if nmcli -t -f ACTIVE,SSID dev wifi | grep -q \"^yes:" + root.connectingSSID + "\"; then echo \"Connection verified\" >&2; exit 0; else echo \"Connection failed verification\" >&2; exit 4; fi; else exit $exit_code; fi"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    console.log("WiFi connection stdout:", text.trim())
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                root.lastConnectionError = text.trim()
                console.log("WiFi connection debug output:", text.trim())
            }
        }
        
        onExited: (exitCode) => {
            console.log("WiFi connection with password result:", exitCode)
            console.log("Error output:", root.lastConnectionError)
            
            if (exitCode === 0) {
                root.connectionStatus = "connected"
                root.passwordDialogShouldReopen = false
                console.log("Connected to WiFi with password successfully")
                ToastService.showInfo("Connected to " + root.connectingSSID)
                NetworkService.setNetworkPreference("wifi")
                NetworkService.delayedRefreshNetworkStatus()
                
                // Immediately update savedWifiNetworks to include the new connection
                if (!root.savedWifiNetworks.some((saved) => saved.ssid === root.connectingSSID)) {
                    let updatedSaved = [...root.savedWifiNetworks];
                    updatedSaved.push({"ssid": root.connectingSSID, "saved": true});
                    root.savedWifiNetworks = updatedSaved;
                }
                
                // Update wifiNetworks to reflect the change
                let updatedNetworks = [...root.wifiNetworks];
                for (let i = 0; i < updatedNetworks.length; i++) {
                    if (updatedNetworks[i].ssid === root.connectingSSID) {
                        updatedNetworks[i].saved = true;
                        updatedNetworks[i].connected = true;
                        break;
                    }
                }
                root.wifiNetworks = updatedNetworks;
            } else if (exitCode === 4) {
                // Connection activation failed - likely invalid credentials
                if (root.lastConnectionError.includes("Secrets were required") || 
                    root.lastConnectionError.includes("authentication") ||
                    root.lastConnectionError.includes("AUTH_TIMED_OUT")) {
                    root.connectionStatus = "invalid_password"
                    root.passwordDialogShouldReopen = true
                    console.log("Invalid password detected")
                    ToastService.showError("Invalid password for " + root.connectingSSID)
                } else {
                    root.connectionStatus = "failed"
                    console.log("Connection failed - not password related")
                    ToastService.showError("Failed to connect to " + root.connectingSSID)
                }
            } else if (exitCode === 3 || exitCode === 124) {
                root.connectionStatus = "failed"
                console.log("Connection timed out")
                ToastService.showError("Connection to " + root.connectingSSID + " timed out")
            } else {
                root.connectionStatus = "failed"
                console.log("WiFi connection with password failed")
                ToastService.showError("Failed to connect to " + root.connectingSSID)
            }
            root.wifiPassword = "" // Clear password
            scanWifi()
            statusResetTimer.start()
        }

    }

    // WiFi Disconnect Process
    Process {
        id: wifiDisconnector
        command: ["bash", "-c", "WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device | grep wifi | cut -d: -f1 | head -1); [ -n \"$WIFI_DEV\" ] && nmcli device disconnect \"$WIFI_DEV\""]
        running: false
        
        onExited: (exitCode) => {
            console.log("WiFi disconnect result:", exitCode)
            if (exitCode === 0) {
                console.log("Successfully disconnected from WiFi")
                ToastService.showInfo("Disconnected from WiFi")
                root.currentWifiSSID = ""
                root.connectionStatus = ""
                NetworkService.refreshNetworkStatus()
            } else {
                console.log("Failed to disconnect from WiFi")
                ToastService.showError("Failed to disconnect from WiFi")
            }
        }

        stderr: SplitParser {
            splitMarker: "\\n"
            onRead: (data) => {
                console.log("WiFi disconnect stderr:", data)
            }
        }
    }

    // WiFi Forget Network Process
    Process {
        id: wifiForget
        command: ["bash", "-c", "nmcli connection delete \"" + root.forgetSSID + "\" || nmcli connection delete id \"" + root.forgetSSID + "\""]
        running: false
        
        onExited: (exitCode) => {
            console.log("WiFi forget result:", exitCode)
            if (exitCode === 0) {
                console.log("Successfully forgot WiFi network:", root.forgetSSID)
                ToastService.showInfo("Forgot network \"" + root.forgetSSID + "\"")
                
                // If we forgot the currently connected network, clear connection status
                if (root.forgetSSID === root.currentWifiSSID) {
                    root.currentWifiSSID = "";
                    root.connectionStatus = "";
                    NetworkService.refreshNetworkStatus();
                }
                
                // Update savedWifiNetworks to remove the forgotten network
                root.savedWifiNetworks = root.savedWifiNetworks.filter((saved) => {
                    return saved.ssid !== root.forgetSSID;
                });
                
                // Update wifiNetworks - create new array with updated objects
                let updatedNetworks = [];
                for (let i = 0; i < root.wifiNetworks.length; i++) {
                    let network = root.wifiNetworks[i];
                    if (network.ssid === root.forgetSSID) {
                        let updatedNetwork = Object.assign({}, network);
                        updatedNetwork.saved = false;
                        updatedNetwork.connected = false;
                        updatedNetworks.push(updatedNetwork);
                    } else {
                        updatedNetworks.push(network);
                    }
                }
                root.wifiNetworks = updatedNetworks;
                root.networksUpdated();
            } else {
                console.log("Failed to forget WiFi network:", root.forgetSSID)
                ToastService.showError("Failed to forget network \"" + root.forgetSSID + "\"")
            }
            root.forgetSSID = "" // Clear SSID
        }

        stderr: SplitParser {
            splitMarker: "\\n"
            onRead: (data) => {
                console.log("WiFi forget stderr:", data)
            }
        }
    }

    // WiFi Network Info Fetcher Process - Using detailed nmcli output
    Process {
        id: wifiInfoFetcher
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,FREQ,RATE,MODE,CHAN,WPA-FLAGS,RSN-FLAGS", "dev", "wifi", "list"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                let details = "";
                if (text.trim()) {
                    let lines = text.trim().split('\n');
                    for (let line of lines) {
                        let parts = line.split(':');
                        if (parts.length >= 9 && parts[0] === root.networkInfoSSID) {
                            let ssid = parts[0] || "Unknown";
                            let signal = parts[1] || "0";
                            let security = parts[2] || "Open";
                            let freq = parts[3] || "Unknown";
                            let rate = parts[4] || "Unknown";
                            let mode = parts[5] || "Unknown";
                            let channel = parts[6] || "Unknown";
                            let wpaFlags = parts[7] || "";
                            let rsnFlags = parts[8] || "";
                            
                            // Determine band from frequency
                            let band = "Unknown";
                            let freqNum = parseInt(freq);
                            if (freqNum >= 2400 && freqNum <= 2500) {
                                band = "2.4 GHz";
                            } else if (freqNum >= 5000 && freqNum <= 6000) {
                                band = "5 GHz";
                            } else if (freqNum >= 6000) {
                                band = "6 GHz";
                            }
                            
                            details = "Network Name: " + ssid + "\\n";
                            details += "Signal Strength: " + signal + "%\\n";
                            details += "Security: " + (security === "" ? "Open" : security) + "\\n";
                            details += "Frequency: " + freq + " MHz\\n";
                            details += "Band: " + band + "\\n";
                            details += "Channel: " + channel + "\\n";
                            details += "Mode: " + mode + "\\n";
                            details += "Max Rate: " + rate + " Mbit/s\\n";
                            
                            if (wpaFlags !== "") {
                                details += "WPA Flags: " + wpaFlags + "\\n";
                            }
                            if (rsnFlags !== "") {
                                details += "RSN Flags: " + rsnFlags + "\\n";
                            }
                            
                            break;
                        }
                    }
                }
                
                if (details === "") {
                    details = "Network information not found or network not available.";
                }
                
                root.networkInfoDetails = details;
                root.networkInfoLoading = false;
                console.log("Network info fetched for:", root.networkInfoSSID);
            }
        }
        
        onExited: (exitCode) => {
            root.networkInfoLoading = false;
            if (exitCode !== 0) {
                console.log("Failed to fetch network info, exit code:", exitCode);
                root.networkInfoDetails = "Failed to fetch network information";
            }
        }
        
        stderr: SplitParser {
            splitMarker: "\\n"
            onRead: (data) => {
                console.log("WiFi info stderr:", data);
            }
        }
    }

}
