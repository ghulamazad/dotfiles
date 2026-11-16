// Clock panel: today's date and a month calendar (weeks start on Monday).
// Use the arrows to change month; it returns to the current month on opening.
// UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PopPanel {
        id: win
        required property var modelData
        screen: modelData
        name: "clock"
        align: "center"
        cardWidth: 320

        SystemClock { id: clock; precision: SystemClock.Minutes }

        property int viewYear: clock.date.getFullYear()
        property int viewMonth: clock.date.getMonth()

        onOpenChanged: if (open) { viewYear = clock.date.getFullYear(); viewMonth = clock.date.getMonth(); }

        function shift(delta) {
            const d = new Date(viewYear, viewMonth + delta, 1);
            viewYear = d.getFullYear();
            viewMonth = d.getMonth();
        }

        // 42 cells starting on the Monday on or before the 1st of the shown month.
        readonly property var cells: {
            const first = new Date(viewYear, viewMonth, 1);
            const offset = (first.getDay() + 6) % 7;
            const out = [];
            for (let i = 0; i < 42; i++) {
                const d = new Date(viewYear, viewMonth, 1 - offset + i);
                out.push({ day: d.getDate(), inMonth: d.getMonth() === viewMonth,
                           today: d.toDateString() === clock.date.toDateString() });
            }
            return out;
        }

        Column {
            width: parent.width
            spacing: 2
            Txt { text: Qt.formatDateTime(clock.date, "hh:mm AP"); font.pixelSize: 34; font.bold: true }
            Txt { text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy"); color: Theme.subtext }
        }

        Divider {}

       Item { 
        width: parent.width
        height: 32
            // Left arrow
            BarButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: win.shift(-1)

                Txt { text: Icons.chevronLeft }
            }

            // Exactly centered title
            Txt {
                anchors.centerIn: parent
                text: Qt.formatDate(
                    new Date(win.viewYear, win.viewMonth, 1),
                    "MMMM yyyy"
                )
                font.bold: true
                font.pixelSize: 16
            }

            // Right arrow
            BarButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: win.shift(1)

                Txt { text: Icons.chevronRight }
            }
        }

        Grid {
            width: parent.width
            columns: 7

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: Txt {
                    required property string modelData
                    width: parent.width / 7
                    height: 24
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.subtext
                    font.pixelSize: Config.fontSize - 2
                }
            }

            Repeater {
                model: win.cells
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width / 7
                    height: 30
                    color: modelData.today ? Theme.accent : "transparent"
                    Txt {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: parent.modelData.day
                        color: parent.modelData.today ? Theme.bg : (parent.modelData.inMonth ? Theme.text : Theme.muted)
                    }
                }
            }
        }
    }
}
