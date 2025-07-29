import QtQuick
import QtQuick.Effects
import qs.Common
import qs.Widgets

Column {
    width: parent.width
    spacing: Theme.spacingM

    // Profile Image Preview and Input
    Column {
        width: parent.width
        spacing: Theme.spacingM

        Text {
            text: "Profile Image"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            font.weight: Font.Medium
        }

        // Profile Image Preview with circular crop
        Row {
            width: parent.width
            spacing: Theme.spacingM

            // Circular profile image preview
            Item {
                id: avatarContainer

                property bool hasImage: avatarImageSource.status === Image.Ready

                width: 54
                height: 54

                // This rectangle provides the themed ring via its border.
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: Theme.primary
                    border.width: 1 // The ring is 1px thick.
                    visible: parent.hasImage
                }

                // Hidden Image loader. Its only purpose is to load the texture.
                Image {
                    id: avatarImageSource

                    source: {
                        if (profileImageInput.text === "")
                            return "";

                        if (profileImageInput.text.startsWith("/"))
                            return "file://" + profileImageInput.text;

                        return profileImageInput.text;
                    }
                    smooth: true
                    asynchronous: true
                    mipmap: true
                    cache: true
                    visible: false // This item is never shown directly.
                }

                MultiEffect {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: avatarImageSource
                    maskEnabled: true
                    maskSource: settingsCircularMask
                    visible: avatarContainer.hasImage
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }

                Item {
                    id: settingsCircularMask

                    width: 54 - 10
                    height: 54 - 10
                    layer.enabled: true
                    layer.smooth: true
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "black"
                        antialiasing: true
                    }

                }

                // Fallback for when there is no image.
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.primary
                    visible: !parent.hasImage

                    DankIcon {
                        anchors.centerIn: parent
                        name: "person"
                        size: Theme.iconSize + 8
                        color: Theme.primaryText
                    }

                }

                // Error icon for when the image fails to load.
                DankIcon {
                    anchors.centerIn: parent
                    name: "warning"
                    size: Theme.iconSize + 8
                    color: Theme.primaryText
                    visible: profileImageInput.text !== "" && avatarImageSource.status === Image.Error
                }

            }

            // Input field
            Column {
                width: parent.width - 80 - Theme.spacingM
                spacing: Theme.spacingS

                Rectangle {
                    width: parent.width
                    height: 48
                    radius: Theme.cornerRadius
                    color: Theme.surfaceVariant
                    border.color: profileImageInput.activeFocus ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                    border.width: profileImageInput.activeFocus ? 2 : 1

                    DankTextField {
                        id: profileImageInput

                        anchors.fill: parent
                        textColor: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeMedium
                        text: Prefs.profileImage
                        placeholderText: "Enter image path or URL..."
                        backgroundColor: "transparent"
                        normalBorderColor: "transparent"
                        focusedBorderColor: "transparent"
                        onEditingFinished: {
                            Prefs.setProfileImage(text);
                        }
                    }

                }

                Text {
                    text: "Local filesystem path or URL to an image file."
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

            }

        }

    }

}
