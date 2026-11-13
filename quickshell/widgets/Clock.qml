// Date and time, updated once a minute.
import QtQuick
import Quickshell
import qs.components

Txt {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "ddd d MMM   HH:mm")
    font.bold: true
}
