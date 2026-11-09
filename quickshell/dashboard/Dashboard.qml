// Dashboard (SUPER+D or click the clock): calendar, resources, network,
// battery, current workspace and shortcuts, including the screenshot buttons.
//
// CPU temperature is shown only where the kernel exposes a sensor; in a VM it
// reads "not available" instead of pretending.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
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

        open: UIState.dashboard
        layerNamespace: "qs-dashboard"
        onCloseRequested: UIState.closeAll()

        property date viewDate: new Date()
        readonly property int year: viewDate.getFullYear()
        readonly property int month: viewDate.getMonth()
        // Monday-first grid: 0 = Monday.
        readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7
        readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
        readonly property date today: new Date()

        onOpenChanged: {
            SysInfo.sampleTemp = open;      // temperature is polled only while visible
            if (open) viewDate = new Date();
        }

        function shiftMonth(delta) {
            viewDate = new Date(year, month + delta, 1);
        }

        // Close first so the dashboard itself is not captured, then give the
        // overlay a moment to fade. Fixed argument list: script path and mode.
        function screenshot(mode) {
            UIState.closeAll();
            Quickshell.execDetached(["sh", "-c", "sleep 0.35; exec \"$1\" \"$2\"", "sh",
                                     Config.scriptsDir + "/screenshot.sh", mode]);
        }

        Card {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Config.barHeight + 8
            width: 720
            height: 400
            opacity: win.progress
            scale: 0.97 + 0.03 * win.progress

            MouseArea { anchors.fill: parent }

            // ---------------------------------------------- left: calendar
            Column {
                x: 24
                y: 20
                width: 300
                spacing: 12

                Txt {
                    text: Qt.formatDateTime(win.today, "HH:mm")
                    font.pixelSize: 40
                    font.bold: true
                }
                Txt {
                    text: Qt.formatDateTime(win.today, "dddd, d MMMM yyyy")
                    color: Theme.subtext
                }

                Item {
                    width: parent.width
                    height: 28

                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDateTime(win.viewDate, "MMMM yyyy")
                        font.bold: true
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        BarButton { onClicked: win.shiftMonth(-1); Txt { text: "‹"; font.pixelSize: 16 } }
                        BarButton { onClicked: win.shiftMonth(1);  Txt { text: "›"; font.pixelSize: 16 } }
                    }
                }

                Grid {
                    columns: 7
                    spacing: 2

                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        delegate: Txt {
                            required property string modelData
                            width: 40
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

                            width: 40
                            height: 30
                            radius: 8
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

            // -------------------------------------------- right: resources
            Column {
                x: 360
                y: 24
                width: 336
                spacing: 14

                Meter {
                    width: parent.width
                    label: "CPU" + (SysInfo.cpuTemp >= 0 ? "   " + SysInfo.cpuTemp.toFixed(0) + " °C" : "   temperature not available")
                    valueText: Math.round(SysInfo.cpu * 100) + "%"
                    fraction: SysInfo.cpu
                }

                Meter {
                    width: parent.width
                    label: "Memory"
                    valueText: SysInfo.ramUsedGiB.toFixed(1) + " / " + SysInfo.ramTotalGiB.toFixed(1) + " GiB"
                    fraction: SysInfo.ramFraction
                    barColor: Theme.accent2
                }

                Meter {
                    visible: Battery.present
                    width: parent.width
                    label: Battery.charging ? "Battery (charging)" : "Battery"
                    valueText: Battery.percent + "%"
                    fraction: Battery.fraction
                    barColor: Theme.green
                }

                Row {
                    spacing: 18
                    Txt { text: "↓ " + SysInfo.formatRate(SysInfo.rxRate) }
                    Txt { text: "↑ " + SysInfo.formatRate(SysInfo.txRate) }
                    Txt {
                        text: Network.connected ? Network.name : "offline"
                        color: Theme.subtext
                        width: 120
                    }
                }

                Txt {
                    text: "Workspace " + (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "?")
                    color: Theme.subtext
                }

                // ------------------------------------------------ shortcuts
                Flow {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: Config.shortcuts
                        delegate: BarButton {
                            required property var modelData
                            onClicked: { UIState.closeAll(); Quickshell.execDetached(modelData.command); }
                            Txt { text: parent.parent.modelData.glyph; color: Theme.accent }
                            Txt { text: parent.parent.modelData.name }
                        }
                    }

                    BarButton {
                        onClicked: UIState.openLauncher("wallpapers")
                        Txt { text: Icons.image; color: Theme.accent }
                        Txt { text: "Wallpapers" }
                    }
                    BarButton {
                        onClicked: win.screenshot("region")
                        Txt { text: Icons.camera; color: Theme.accent }
                        Txt { text: "Region" }
                    }
                    BarButton {
                        onClicked: win.screenshot("screen")
                        Txt { text: Icons.camera; color: Theme.accent }
                        Txt { text: "Screen" }
                    }
                }
            }
        }
    }
}
