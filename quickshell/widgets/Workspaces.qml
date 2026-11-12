// Workspace indicators. Hyprland owns the workspaces; this only displays them
// and asks Hyprland to switch. Named/special workspaces have id <= 0 and are hidden.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import qs.components
import qs.themes

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: 24

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: ws
                required property var modelData

                visible: modelData.id > 0   // Row skips invisible items
                width: 26
                height: 22
                radius: Config.radius
                color: modelData.focused ? Theme.accent
                     : modelData.urgent ? Theme.red
                     : modelData.active ? Theme.surface2
                     : "transparent"

                Txt {
                    anchors.centerIn: parent
                    text: ws.modelData.id
                    font.bold: ws.modelData.focused
                    color: ws.modelData.focused ? Theme.bg : Theme.subtext
                }

                MouseArea {
                    anchors.fill: parent
                    // activate() is Lua-aware in Quickshell >= 0.3.0 (checked in its
                    // changelog and source), so it works with Hyprland's Lua config.
                    onClicked: ws.modelData.activate()
                }
            }
        }
    }

    // Scroll over the indicators to change workspace. NoButton lets clicks
    // fall through to the pills below.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            // Hyprland's dispatch takes a Lua expression since 0.55; old
            // strings like "workspace e+1" are a syntax error there.
            const rel = wheel.angleDelta.y > 0 ? "e-1" : "e+1";
            Hyprland.dispatch('hl.dsp.focus({ workspace = "' + rel + '" })');
        }
    }
}
