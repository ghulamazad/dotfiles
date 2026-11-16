// Weekday and time, centered in the bar. Click opens the calendar panel.
// Updates once a minute.
import QtQuick
import Quickshell
import qs.components
import qs.services

BarButton {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    active: UIState.panel === "clock"
    onClicked: UIState.togglePanel("clock")

    Txt {
        text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy hh:mm AP")
    }
}
