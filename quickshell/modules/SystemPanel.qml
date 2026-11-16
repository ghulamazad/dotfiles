// System panel (the CPU icon): CPU, memory, load, uptime and the busiest
// processes. Sampling runs only while the panel is open (services/SystemStats.qml).
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
        name: "system"

        onOpenChanged: SystemStats.active = open

        function gb(kb) { return (kb / 1048576).toFixed(1); }

        PanelHeader { title: "System" }

        SectionLabel { text: SystemStats.uptime !== "" ? "UP " + SystemStats.uptime.toUpperCase() : "READING…"; width: parent.width }

        Divider {}

        Meter {
            label: "CPU"
            valueText: Math.round(SystemStats.cpu * 100) + "%"
            fraction: SystemStats.cpu
            barColor: SystemStats.cpu > 0.85 ? Theme.red : Theme.accent
        }
        Meter {
            label: "MEMORY"
            valueText: win.gb(SystemStats.memUsed) + " / " + win.gb(SystemStats.memTotal) + " GB"
            fraction: SystemStats.memTotal > 0 ? SystemStats.memUsed / SystemStats.memTotal : 0
            barColor: SystemStats.memTotal > 0 && SystemStats.memUsed / SystemStats.memTotal > 0.9 ? Theme.red : Theme.accent
        }

        Item {
            width: parent.width
            height: 22
            SectionLabel { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "LOAD" }
            Txt { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: SystemStats.load }
        }

        Divider {}

        Column {
            width: parent.width
            spacing: 4
            SectionLabel { text: "TOP PROCESSES"; height: 24 }

            Repeater {
                model: SystemStats.top

                delegate: Item {
                    required property var modelData
                    width: parent.width
                    height: 22
                    Txt { anchors.left: parent.left; anchors.right: pc.left; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: modelData.name }
                    Txt { id: pc; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: modelData.cpu.toFixed(1) + "%"; color: Theme.subtext }
                }
            }
        }
    }
}
