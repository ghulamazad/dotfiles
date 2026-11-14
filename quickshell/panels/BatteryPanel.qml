// Battery: percentage and time remaining, nothing else.
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

        open: UIState.battery
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        PanelFrame {
            progress: win.progress
            cardWidth: 300

            PanelHeader { title: "Battery" }

            Txt {
                width: parent.width
                visible: !Battery.present
                text: "No battery found."
                color: Theme.subtext
            }

            Txt {
                visible: Battery.present
                text: Battery.percent + "%"
                font.pixelSize: 36
                font.bold: true
                color: Battery.low ? Theme.red : Theme.text
            }
            Txt {
                width: parent.width
                visible: Battery.present
                text: Battery.charging ? "Charging" : "On battery"
                color: Theme.subtext
            }
            Txt {
                width: parent.width
                visible: Battery.present && Battery.timeText !== ""
                text: (Battery.charging ? "Full in " : "About ") + Battery.timeText + (Battery.charging ? "" : " left")
                color: Theme.subtext
            }
        }
    }
}
