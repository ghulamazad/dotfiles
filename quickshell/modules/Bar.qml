// The single top panel, one per monitor.
//   left:   app menu, workspaces, active window title
//   center: clock (opens dashboard / calendar)
//   right:  tray, CPU/RAM, network/bluetooth/audio/battery, notifications, power
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

                BarButton {
                    active: UIState.launcher
                    onClicked: {
                        if (UIState.launcher) UIState.closeAll();
                        else UIState.openLauncher("apps");
                    }
                    Txt { text: Icons.apps; font.pixelSize: 15 }
                    Txt { text: "Apps" }
                }

                Workspaces {}

                ActiveWindow { anchors.verticalCenter: parent.verticalCenter }
            }

            Clock {
                anchors.centerIn: parent
                active: UIState.dashboard
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Tray { anchors.verticalCenter: parent.verticalCenter }

                Meters {}

                StatusIcons { active: UIState.quickSettings }

                BarButton {
                    active: UIState.notificationCenter
                    onClicked: UIState.toggle("notificationCenter")
                    Txt {
                        text: Notifs.dnd ? Icons.bellOff : Icons.bell
                        font.pixelSize: 15
                        color: Notifs.dnd ? Theme.yellow : Theme.text
                    }
                }

                BarButton {
                    active: UIState.power
                    onClicked: UIState.toggle("power")
                    Txt { text: Icons.power; font.pixelSize: 15; color: Theme.red }
                }
            }
        }
    }
}
