// Weekday and time, centered in the bar. Click toggles the date.
// Updates once a minute.
import QtQuick
import Quickshell
import qs.components

BarButton {
    property bool showDate: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    onClicked: showDate = !showDate

    Txt {
        text: Qt.formatDateTime(clock.date, showDate ? "d MMMM yyyy" : "dddd HH:mm")
    }
}
