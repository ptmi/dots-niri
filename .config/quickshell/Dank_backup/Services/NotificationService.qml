pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Services

Singleton {
    id: root

    readonly property list<NotifWrapper> notifications: []
    readonly property list<NotifWrapper> popups: notifications.filter(n => n.popup)
    
    // Android 16-style grouped notifications
    readonly property var groupedNotifications: getGroupedNotifications()
    readonly property var groupedPopups: getGroupedPopups()
    
    property var expandedGroups: ({}) // Track which groups are expanded
    property var expandedMessages: ({}) // Track which individual messages are expanded
    
    // Notification persistence settings
    property int maxStoredNotifications: 100
    property int maxNotificationAge: 7 * 24 * 60 * 60 * 1000 // 7 days in milliseconds
    property var persistedNotifications: ([]) // Stored notification history

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        inlineReplySupported: true

        onNotification: notif => {
            console.log("=== RAW NOTIFICATION DATA ===");
            console.log("appName:", notif.appName);
            console.log("summary:", notif.summary);
            console.log("body:", notif.body);
            console.log("appIcon:", notif.appIcon);
            console.log("image:", notif.image);
            console.log("urgency:", notif.urgency);
            console.log("hasInlineReply:", notif.hasInlineReply);
            console.log("=============================");
            
            // Check if notification should be shown based on settings
            if (!NotificationSettings.shouldShowNotification(notif)) {
                console.log("Notification blocked by settings for app:", notif.appName);
                return;
            }
            
            notif.tracked = true;

            const wrapper = notifComponent.createObject(root, {
                popup: true,
                notification: notif
            });

            if (wrapper) {
                const groupKey = getGroupKey(wrapper);
                console.log("New notification added to group:", groupKey, "Expansion state:", expandedGroups[groupKey] || false);
                // Handle media notification replacement
                if (wrapper.isMedia) {
                    handleMediaNotification(wrapper);
                } else {
                    root.notifications.push(wrapper);
                }
                
                // Don't auto-expand groups - let user control expansion state
                
                // Add to persistent storage (only for non-transient notifications)
                if (!notif.transient) {
                    addToPersistentStorage(wrapper);
                }
                
                console.log("Notification added. Total notifications:", root.notifications.length);
                console.log("Grouped notifications:", root.groupedNotifications.length);
            } else {
                console.error("Failed to create notification wrapper");
            }
        }
    }

    component NotifWrapper: QtObject {
        id: wrapper

        property bool popup: true
        readonly property date time: new Date()
        readonly property string timeStr: {
            const now = new Date();
            const diff = now.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        required property Notification notification
        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string cleanAppIcon: {
            if (!appIcon) return "";
            if (appIcon.startsWith("file://")) {
                return appIcon.substring(7);
            }
            return appIcon;
        }
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property string cleanImage: {
            if (!image) return "";
            if (image.startsWith("file://")) {
                return image.substring(7);
            }
            return image;
        }
        readonly property int urgency: notification.urgency
        readonly property list<NotificationAction> actions: notification.actions

        // Enhanced properties for better handling
        readonly property bool hasImage: image && image.length > 0
        readonly property bool hasAppIcon: appIcon && appIcon.length > 0
        readonly property bool isConversation: notification.hasInlineReply
        readonly property bool isMedia: isMediaNotification()
        readonly property bool isSystem: isSystemNotification()
        
        function isMediaNotification() {
            const appNameLower = appName.toLowerCase();
            const summaryLower = summary.toLowerCase();
            
            // Check for media apps
            if (appNameLower.includes("spotify") || 
                appNameLower.includes("vlc") || 
                appNameLower.includes("mpv") || 
                appNameLower.includes("music") || 
                appNameLower.includes("player") ||
                appNameLower.includes("youtube") ||
                appNameLower.includes("media")) {
                return true;
            }
            
            // Check for media-related summary text
            if (summaryLower.includes("now playing") ||
                summaryLower.includes("playing") ||
                summaryLower.includes("paused") ||
                summaryLower.includes("track")) {
                return true;
            }
            
            // Check for media actions
            for (const action of actions) {
                const actionId = action.identifier.toLowerCase();
                if (actionId.includes("play") || 
                    actionId.includes("pause") || 
                    actionId.includes("next") || 
                    actionId.includes("previous") ||
                    actionId.includes("media")) {
                    return true;
                }
            }
            
            return false;
        }
        
        function isSystemNotification() {
            const appNameLower = appName.toLowerCase();
            const summaryLower = summary.toLowerCase();
            
            // Check for system apps
            if (appNameLower.includes("system") ||
                appNameLower.includes("networkmanager") ||
                appNameLower.includes("upower") ||
                appNameLower.includes("notification-daemon") ||
                appNameLower.includes("systemd") ||
                appNameLower.includes("update") ||
                appNameLower.includes("battery") ||
                appNameLower.includes("network") ||
                appNameLower.includes("wifi") ||
                appNameLower.includes("bluetooth")) {
                return true;
            }
            
            // Check for system-related summary text
            if (summaryLower.includes("battery") ||
                summaryLower.includes("power") ||
                summaryLower.includes("update") ||
                summaryLower.includes("connected") ||
                summaryLower.includes("disconnected") ||
                summaryLower.includes("network") ||
                summaryLower.includes("wifi") ||
                summaryLower.includes("bluetooth")) {
                return true;
            }
            
            return false;
        }




        

        readonly property Connections conn: Connections {
            target: wrapper.notification.Retainable

            function onDropped(): void {
                const index = root.notifications.indexOf(wrapper);
                if (index !== -1) {
                    // Get the group key before removing the notification
                    const groupKey = getGroupKey(wrapper);
                    root.notifications.splice(index, 1);
                    
                    // Check if this group now has no notifications left
                    const remainingInGroup = root.notifications.filter(n => getGroupKey(n) === groupKey);
                    if (remainingInGroup.length === 0) {
                        // Immediately clear expansion state for empty group
                        clearGroupExpansionState(groupKey);
                    }
                    
                    // Clean up all expansion states
                    cleanupExpansionStates();
                }
            }

            function onAboutToDestroy(): void {
                wrapper.destroy();
            }
        }
    }

    Component {
        id: notifComponent
        NotifWrapper {}
    }

    // Helper functions
    function clearAllNotifications() {
        // Create a copy of the array to avoid modification during iteration
        const notificationsCopy = [...root.notifications];
        for (const notif of notificationsCopy) {
            notif.notification.dismiss();
        }
        // Note: Expansion states will be cleaned up by onDropped as notifications are removed
    }

    function dismissNotification(wrapper) {
        wrapper.notification.dismiss();
    }

    function handleMediaNotification(newMediaWrapper) {
        const groupKey = getGroupKey(newMediaWrapper);
        
        // Find and replace any existing media notification from the same app
        for (let i = notifications.length - 1; i >= 0; i--) {
            const existing = notifications[i];
            if (existing.isMedia && getGroupKey(existing) === groupKey) {
                // Replace the existing media notification
                existing.notification.dismiss();
                break;
            }
        }
        
        // Add the new media notification
        root.notifications.push(newMediaWrapper);
    }

    // Android 16-style notification grouping functions
    function getGroupKey(wrapper) {
        const appName = wrapper.appName.toLowerCase();
        
        // Media notifications: replace previous media notification from same app
        if (wrapper.isMedia) {
            return `${appName}:media`;
        }
        
        // System notifications: group by category
        if (wrapper.isSystem) {
            const summary = wrapper.summary.toLowerCase();
            
            if (summary.includes("battery") || summary.includes("power")) {
                return "system:battery";
            }
            if (summary.includes("network") || summary.includes("wifi") || summary.includes("connected") || summary.includes("disconnected")) {
                return "system:network";
            }
            if (summary.includes("update") || summary.includes("upgrade")) {
                return "system:updates";
            }
            if (summary.includes("bluetooth")) {
                return "system:bluetooth";
            }
            
            // Default system grouping
            return "system:general";
        }
        
        // Conversation apps with inline reply
        if (wrapper.isConversation) {
            const summary = wrapper.summary.toLowerCase();
            
            // Group by conversation/channel name from summary
            if (summary.includes("#")) {
                const channelMatch = summary.match(/#[\w-]+/);
                if (channelMatch) {
                    return `${appName}:${channelMatch[0]}`;
                }
            }
            
            // Group by sender/conversation name if meaningful
            if (summary && !summary.includes("new message") && !summary.includes("notification")) {
                return `${appName}:${summary}`;
            }
            
            // Default conversation grouping
            return `${appName}:conversation`;
        }
        
        // Default: Group by app
        return appName;
    }

    function getGroupedNotifications() {
        const groups = {};
        
        for (const notif of notifications) {
            const groupKey = getGroupKey(notif);
            if (!groups[groupKey]) {
                groups[groupKey] = {
                    key: groupKey,
                    appName: notif.appName,
                    notifications: [],
                    latestNotification: null,
                    count: 0,
                    hasInlineReply: false,
                    isConversation: notif.isConversation,
                    isMedia: notif.isMedia,
                    isSystem: notif.isSystem
                };
            }
            
            groups[groupKey].notifications.unshift(notif);
            groups[groupKey].latestNotification = groups[groupKey].notifications[0];
            groups[groupKey].count = groups[groupKey].notifications.length;
            
            if (notif.notification.hasInlineReply) {
                groups[groupKey].hasInlineReply = true;
            }
        }
        
        return Object.values(groups).sort((a, b) => {
            return b.latestNotification.time.getTime() - a.latestNotification.time.getTime();
        });
    }

    function getGroupedPopups() {
        const groups = {};
        
        for (const notif of popups) {
            const groupKey = getGroupKey(notif);
            if (!groups[groupKey]) {
                groups[groupKey] = {
                    key: groupKey,
                    appName: notif.appName,
                    notifications: [],
                    latestNotification: null,
                    count: 0,
                    hasInlineReply: false,
                    isConversation: notif.isConversation,
                    isMedia: notif.isMedia,
                    isSystem: notif.isSystem
                };
            }
            
            groups[groupKey].notifications.unshift(notif);
            groups[groupKey].latestNotification = groups[groupKey].notifications[0];
            groups[groupKey].count = groups[groupKey].notifications.length;
            
            if (notif.notification.hasInlineReply) {
                groups[groupKey].hasInlineReply = true;
            }
        }
        
        return Object.values(groups).sort((a, b) => {
            return b.latestNotification.time.getTime() - a.latestNotification.time.getTime();
        });
    }

    function toggleGroupExpansion(groupKey) {
        let newExpandedGroups = {};
        for (const key in expandedGroups) {
            newExpandedGroups[key] = expandedGroups[key];
        }
        newExpandedGroups[groupKey] = !newExpandedGroups[groupKey];
        expandedGroups = newExpandedGroups;
    }

    function dismissGroup(groupKey) {
        console.log("Completely dismissing group:", groupKey);
        const group = groupedNotifications.find(g => g.key === groupKey);
        if (group) {
            for (const notif of group.notifications) {
                notif.notification.dismiss();
            }
        }
        // Note: Expansion state will be cleaned up by onDropped when notifications are removed
    }
    
    function clearGroupExpansionState(groupKey) {
        // Immediately remove expansion state for a specific group
        let newExpandedGroups = {};
        for (const key in expandedGroups) {
            if (key !== groupKey && expandedGroups[key]) {
                newExpandedGroups[key] = true;
            }
        }
        expandedGroups = newExpandedGroups;
        
        console.log("Cleared expansion state for group:", groupKey);
    }

    function cleanupExpansionStates() {
        // Get all current group keys and message IDs
        const currentGroupKeys = new Set(groupedNotifications.map(g => g.key));
        const currentMessageIds = new Set();
        
        for (const group of groupedNotifications) {
            for (const notif of group.notifications) {
                currentMessageIds.add(notif.notification.id);
            }
        }
        
        // Clean up expanded groups that no longer exist
        let newExpandedGroups = {};
        for (const key in expandedGroups) {
            if (currentGroupKeys.has(key) && expandedGroups[key]) {
                newExpandedGroups[key] = true;
            }
        }
        expandedGroups = newExpandedGroups;
        
        // Clean up expanded messages that no longer exist
        let newExpandedMessages = {};
        for (const messageId in expandedMessages) {
            if (currentMessageIds.has(messageId) && expandedMessages[messageId]) {
                newExpandedMessages[messageId] = true;
            }
        }
        expandedMessages = newExpandedMessages;
    }

    function toggleMessageExpansion(messageId) {
        let newExpandedMessages = {};
        for (const key in expandedMessages) {
            newExpandedMessages[key] = expandedMessages[key];
        }
        newExpandedMessages[messageId] = !newExpandedMessages[messageId];
        expandedMessages = newExpandedMessages;
    }

    function getGroupTitle(group) {
        if (group.count === 1) {
            return group.latestNotification.summary;
        }
        
        if (group.isMedia) {
            return "Now Playing";
        }
        
        if (group.isSystem) {
            const keyParts = group.key.split(":");
            if (keyParts.length > 1) {
                const systemCategory = keyParts[1];
                switch (systemCategory) {
                    case "battery": return `${group.count} Battery alerts`;
                    case "network": return `${group.count} Network updates`;
                    case "updates": return `${group.count} System updates`;
                    case "bluetooth": return `${group.count} Bluetooth updates`;
                    default: return `${group.count} System notifications`;
                }
            }
            return `${group.count} System notifications`;
        }
        
        if (group.isConversation) {
            const keyParts = group.key.split(":");
            if (keyParts.length > 1) {
                const conversationKey = keyParts[keyParts.length - 1];
                if (conversationKey !== "conversation") {
                    return `${conversationKey}: ${group.count} messages`;
                }
            }
            return `${group.count} new messages`;
        }
        
        return `${group.count} notifications`;
    }

    function getGroupBody(group) {
        if (group.count === 1) {
            return group.latestNotification.body;
        }
        
        if (group.isMedia) {
            const latest = group.latestNotification;
            if (latest.body && latest.body.length > 0) {
                return latest.body;
            }
            return latest.summary;
        }
        
        if (group.isSystem) {
            return `Latest: ${group.latestNotification.summary}`;
        }
        
        if (group.isConversation) {
            const latest = group.latestNotification;
            if (latest.body && latest.body.length > 0) {
                return latest.body;
            }
            return "Tap to view conversation";
        }
        
        return `Latest: ${group.latestNotification.summary}`;
    }

    // Notification persistence functions
    function addToPersistentStorage(wrapper) {
        const persistedNotif = {
            id: wrapper.notification.id,
            appName: wrapper.appName,
            summary: wrapper.summary,
            body: wrapper.body,
            appIcon: wrapper.appIcon,
            image: wrapper.image,
            urgency: wrapper.urgency,
            timestamp: wrapper.time.getTime(),
            isConversation: wrapper.isConversation,
            isMedia: wrapper.isMedia,
            isSystem: wrapper.isSystem
        };
        
        // Add to beginning of array
        persistedNotifications.unshift(persistedNotif);
        
        // Clean up old notifications
        cleanupPersistentStorage();
    }

    function cleanupPersistentStorage() {
        const now = new Date().getTime();
        let newPersisted = [];
        
        for (let i = 0; i < persistedNotifications.length && i < maxStoredNotifications; i++) {
            const notif = persistedNotifications[i];
            if (now - notif.timestamp < maxNotificationAge) {
                newPersisted.push(notif);
            }
        }
        
        persistedNotifications = newPersisted;
    }

    function getPersistentNotificationsByApp(appName) {
        return persistedNotifications.filter(notif => notif.appName.toLowerCase() === appName.toLowerCase());
    }

    function getPersistentNotificationsByType(type) {
        switch (type) {
            case "conversation": return persistedNotifications.filter(notif => notif.isConversation);
            case "media": return persistedNotifications.filter(notif => notif.isMedia);
            case "system": return persistedNotifications.filter(notif => notif.isSystem);
            default: return persistedNotifications;
        }
    }

    function searchPersistentNotifications(query) {
        const searchLower = query.toLowerCase();
        return persistedNotifications.filter(notif => 
            notif.appName.toLowerCase().includes(searchLower) ||
            notif.summary.toLowerCase().includes(searchLower) ||
            notif.body.toLowerCase().includes(searchLower)
        );
    }

    // Initialize persistence on component creation
    Component.onCompleted: {
        cleanupPersistentStorage();
    }
}