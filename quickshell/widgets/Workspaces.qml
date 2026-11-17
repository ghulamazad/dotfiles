// Workspace numbers 1 to 5 are always shown; any other
// workspace in use is added after them. Hyprland owns the workspaces; this only
// displays them and asks Hyprland to switch.
//   active   accent colour, bold, underlined
//   in use   normal text
//   empty    dim
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import qs.components
import qs.themes
import qs.config

Row {
    id: root
    spacing: Config.px(2)

    readonly property var existing: Array.from(Hyprland.workspaces.values).map(w => w.id)
    readonly property var ids: {
        const set = new Set([1, 2, 3, 4, 5]);
        for (const id of existing) if (id > 0) set.add(id);
        return Array.from(set).sort((a, b) => a - b);
    }
    readonly property int current: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

    Repeater {
        model: root.ids

        delegate: Item {
            id: ws
            required property int modelData
            readonly property bool focused: modelData === root.current
            readonly property bool inUse: root.existing.indexOf(modelData) >= 0

            width: Config.px(22)
            height: Config.px(22)

            Txt {
                anchors.centerIn: parent
                text: ws.modelData
                font.bold: ws.focused
                color: ws.focused ? Theme.accent : (ws.inUse ? Theme.text : Theme.muted)
            }

            Rectangle {
                visible: ws.focused
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: Config.px(12)
                height: 2
                color: Theme.accent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // Hyprland >= 0.55 dispatches Lua expressions, not "workspace 3".
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + ws.modelData + " })")
            }
        }
    }
}
