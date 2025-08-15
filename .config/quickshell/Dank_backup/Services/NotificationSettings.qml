pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    // General notification settings
    property bool notificationsEnabled: true
    property bool soundEnabled: true
    property bool persistNotifications: true
    property int defaultTimeout: 5000 // milliseconds
    
    // Grouping settings
    property bool enableSmartGrouping: true
    property bool autoExpandConversations: true
    property bool replaceMediaNotifications: true
    
    // Persistence settings
    property int maxStoredNotifications: 100
    property int notificationRetentionDays: 7
    
    // Display settings
    property bool showNotificationPopups: true
    property bool showAppIcons: true
    property bool showTimestamps: true
    property bool enableInlineReply: true
    property bool showActionButtons: true
    
    // Priority settings
    property bool allowCriticalNotifications: true
    property bool respectDoNotDisturb: true
    
    // App-specific settings
    property var appSettings: ({})
    
    // Do Not Disturb settings
    property bool doNotDisturbMode: false
    property string doNotDisturbStart: "22:00"
    property string doNotDisturbEnd: "08:00"
    property bool allowCriticalInDND: true
    
    // Sound settings
    property string notificationSound: "default"
    property real soundVolume: 0.7
    property bool vibrationEnabled: false
    
    function getAppSetting(appName, setting, defaultValue) {
        const app = appSettings[appName.toLowerCase()];
        if (app && app.hasOwnProperty(setting)) {
            return app[setting];
        }
        return defaultValue;
    }
    
    function setAppSetting(appName, setting, value) {
        let newAppSettings = {};
        for (const app in appSettings) {
            newAppSettings[app] = appSettings[app];
        }
        
        const appKey = appName.toLowerCase();
        if (!newAppSettings[appKey]) {
            newAppSettings[appKey] = {};
        }
        newAppSettings[appKey][setting] = value;
        appSettings = newAppSettings;
        
        // Save to persistent storage
        saveSettings();
    }
    
    function isAppBlocked(appName) {
        const appKey = appName.toLowerCase();
        if (appKey === "notify-send" || appKey === "libnotify") {
            return false;
        }
        return getAppSetting(appName, "blocked", false);
    }
    
    function isAppMuted(appName) {
        return getAppSetting(appName, "muted", false);
    }
    
    function getAppTimeout(appName) {
        return getAppSetting(appName, "timeout", defaultTimeout);
    }
    
    function isInDoNotDisturbMode() {
        if (!doNotDisturbMode && !respectDoNotDisturb) {
            return false;
        }
        
        const now = new Date();
        const currentTime = now.getHours() * 60 + now.getMinutes();
        
        const startParts = doNotDisturbStart.split(":");
        const endParts = doNotDisturbEnd.split(":");
        const startTime = parseInt(startParts[0]) * 60 + parseInt(startParts[1]);
        const endTime = parseInt(endParts[0]) * 60 + parseInt(endParts[1]);
        
        if (startTime <= endTime) {
            // Same day range (e.g., 9:00 - 17:00)
            return currentTime >= startTime && currentTime <= endTime;
        } else {
            // Overnight range (e.g., 22:00 - 08:00)
            return currentTime >= startTime || currentTime <= endTime;
        }
    }
    
    function shouldShowNotification(notification) {
        // Check if notifications are globally disabled
        if (!notificationsEnabled) {
            return false;
        }
        
        // Check if app is blocked
        if (isAppBlocked(notification.appName)) {
            return false;
        }
        
        // DND logic temporarily disabled for all notifications
        // if (isInDoNotDisturbMode()) {
        //     // Allow critical notifications if configured
        //     if (allowCriticalInDND && notification.urgency === 2) {
        //         return true;
        //     }
        //     return false;
        // }
        
        return true;
    }
    
    function shouldPlaySound(notification) {
        if (!soundEnabled) {
            return false;
        }
        
        if (isAppMuted(notification.appName)) {
            return false;
        }
        
        if (isInDoNotDisturbMode() && !allowCriticalInDND) {
            return false;
        }
        
        return true;
    }
    
    function saveSettings() {
        // In a real implementation, this would save to a config file
        console.log("NotificationSettings: Settings saved");
    }
    
    function loadSettings() {
        // In a real implementation, this would load from a config file
        console.log("NotificationSettings: Settings loaded");
    }
    
    function resetToDefaults() {
        notificationsEnabled = true;
        soundEnabled = true;
        persistNotifications = true;
        defaultTimeout = 5000;
        enableSmartGrouping = true;
        autoExpandConversations = true;
        replaceMediaNotifications = true;
        maxStoredNotifications = 100;
        notificationRetentionDays = 7;
        showNotificationPopups = true;
        showAppIcons = true;
        showTimestamps = true;
        enableInlineReply = true;
        showActionButtons = true;
        allowCriticalNotifications = true;
        respectDoNotDisturb = true;
        doNotDisturbMode = false;
        doNotDisturbStart = "22:00";
        doNotDisturbEnd = "08:00";
        allowCriticalInDND = true;
        notificationSound = "default";
        soundVolume = 0.7;
        vibrationEnabled = false;
        appSettings = {};
        
        saveSettings();
    }
    
    Component.onCompleted: {
        loadSettings();
    }
}