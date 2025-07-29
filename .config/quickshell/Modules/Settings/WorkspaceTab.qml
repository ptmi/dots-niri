import QtQuick
import qs.Common
import qs.Widgets

Column {
    width: parent.width
    spacing: Theme.spacingM

    DankToggle {
        text: "Workspace Index Numbers"
        description: "Show workspace index numbers in the top bar workspace switcher"
        checked: Prefs.showWorkspaceIndex
        onToggled: (checked) => {
            return Prefs.setShowWorkspaceIndex(checked);
        }
    }

    DankToggle {
        text: "Workspace Padding"
        description: "Always show a minimum of 3 workspaces, even if fewer are available"
        checked: Prefs.showWorkspacePadding
        onToggled: (checked) => {
            return Prefs.setShowWorkspacePadding(checked);
        }
    }

}
