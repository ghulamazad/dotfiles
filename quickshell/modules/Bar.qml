// The only panel: a flat top bar, one per monitor.
//   left:   Arch logo (opens the launcher), workspaces 1 to 5
//   center: weekday and time (click for the date)
//   right:  tray, Bluetooth, network, sound, CPU, battery
//
// Exclusion mode stays Auto: with three anchors Quickshell reserves exactly the
// bar's height, so Hyprland tiles below it. SUPER+SHIFT+SPACE hides the bar.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services
import qs.themes
import qs.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        visible: UIState.barVisible
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Config.barHeight
        color: Theme.bg
        WlrLayershell.namespace: "qs-bar"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            BarButton {
                onClicked: UIState.toggleLauncher("apps")
                Txt { text: Icons.arch; font.pixelSize: Config.fontSize + 3; color: Theme.accent }
            }
            Workspaces {}
        }

        Clock { anchors.centerIn: parent }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Tray { anchors.verticalCenter: parent.verticalCenter }
            Indicators {}
        }
    }
}
