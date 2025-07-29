import QtQuick
import qs.Common
import qs.Widgets

Column {
    width: parent.width
    spacing: Theme.spacingM

    DankToggle {
        text: "24-Hour Format"
        description: "Use 24-hour time format instead of 12-hour AM/PM"
        checked: Prefs.use24HourClock
        onToggled: (checked) => {
            return Prefs.setClockFormat(checked);
        }
    }

}
