// Calendar popup, opened by clicking the date and time in the bar.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    Overlay {
        id: win
        required property var modelData
        screen: modelData

        open: UIState.calendar
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        property date viewDate: new Date()
        readonly property int year: viewDate.getFullYear()
        readonly property int month: viewDate.getMonth()
        // Monday-first grid: 0 = Monday.
        readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7
        readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
        readonly property date today: new Date()

        onOpenChanged: if (open) viewDate = new Date()

        function shiftMonth(delta) {
            viewDate = new Date(year, month + delta, 1);
        }

        PanelFrame {
            progress: win.progress
            align: "center"
            cardWidth: 340

            Txt {
                text: Qt.formatDateTime(win.today, "HH:mm")
                font.pixelSize: 36
                font.bold: true
            }
            Txt {
                text: Qt.formatDateTime(win.today, "dddd, d MMMM yyyy")
                color: Theme.subtext
            }

            PanelHeader {
                title: Qt.formatDate(win.viewDate, "MMMM yyyy")
                BarButton { onClicked: win.shiftMonth(-1); Txt { text: "‹"; font.pixelSize: 16 } }
                BarButton { onClicked: win.shiftMonth(1);  Txt { text: "›"; font.pixelSize: 16 } }
            }

            Grid {
                columns: 7
                spacing: 2

                Repeater {
                    model: ["M", "T", "W", "T", "F", "S", "S"]
                    delegate: Txt {
                        required property string modelData
                        width: 42
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.subtext
                    }
                }

                Repeater {
                    model: 42
                    delegate: Rectangle {
                        id: cell
                        required property int index

                        readonly property int day: index - win.offset + 1
                        readonly property bool valid: day >= 1 && day <= win.daysInMonth
                        readonly property bool isToday: valid
                            && day === win.today.getDate()
                            && win.month === win.today.getMonth()
                            && win.year === win.today.getFullYear()

                        width: 42
                        height: 30
                        radius: Config.radius
                        color: isToday ? Theme.accent : "transparent"

                        Txt {
                            anchors.centerIn: parent
                            visible: cell.valid
                            text: cell.day
                            color: cell.isToday ? Theme.bg : Theme.text
                            font.bold: cell.isToday
                        }
                    }
                }
            }
        }
    }
}
