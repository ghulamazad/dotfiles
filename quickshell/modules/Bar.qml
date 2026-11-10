// The single top panel, one per monitor.
//   left:   workspaces
//   center: date and time (click opens the calendar)
//   right:  tray, then Bluetooth, network, sound, display, battery. Each icon
//           opens its own panel (see ../panels).
//
// Exclusion mode is left at Auto: with three anchors (top, left, right)
// Quickshell reserves exactly the bar's height, so Hyprland tiles below it.
// No bottom dock exists anywhere in this config.
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

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Config.barHeight
        color: "transparent"
        WlrLayershell.namespace: "qs-bar"

        Rectangle {
            anchors.fill: parent
            color: Theme.panel

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.border
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Workspaces {}
            }

            Clock {
                anchors.centerIn: parent
                active: UIState.calendar
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Tray { anchors.verticalCenter: parent.verticalCenter }

                StatusIcons {}
            }
        }
    }
}
