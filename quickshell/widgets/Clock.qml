// Date and time. Updates once a minute; click opens the dashboard calendar.
import QtQuick
import Quickshell
import qs.components
import qs.services

BarButton {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    onClicked: UIState.toggle("dashboard")

    Txt {
        text: Qt.formatDateTime(clock.date, "ddd d MMM   HH:mm")
        font.bold: true
    }
}
