// Workspace overview (SUPER+Tab): workspaces 1 to 9 with the titles of the
// windows on each. Click one to switch. Windows are listed, not drawn as
// live thumbnails: live previews need the screencopy protocol, which this
// config deliberately does not grant to the shell.
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

        open: UIState.overview
        layerNamespace: "qs-overview"
        onCloseRequested: UIState.closeAll()

        Card {
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 960)
            height: grid.implicitHeight + 48
            opacity: win.progress
            scale: 0.96 + 0.04 * win.progress

            MouseArea { anchors.fill: parent }

            Grid {
                id: grid
                anchors.centerIn: parent
                columns: 3
                spacing: 14

                Repeater {
                    model: 9

                    delegate: Rectangle {
                        id: tile
                        required property int index

                        readonly property int wsId: index + 1
                        readonly property var ws: Array.from(Hyprland.workspaces.values).find(w => w.id === wsId) ?? null
                        readonly property var titles: ws ? Array.from(ws.toplevels.values).map(t => t.title) : []

                        width: 280
                        height: 150
                        radius: Config.radius
                        color: (ws && ws.focused) ? Theme.surface2 : Theme.surface
                        border.width: (ws && ws.focused) ? 2 : 1
                        border.color: (ws && ws.focused) ? Theme.accent : Theme.border

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Txt {
                                text: "Workspace " + tile.wsId
                                font.bold: true
                                color: (tile.ws && tile.ws.focused) ? Theme.accent : Theme.text
                            }
                            Repeater {
                                model: tile.titles.slice(0, 4)
                                delegate: Txt {
                                    required property string modelData
                                    width: tile.width - 24
                                    text: "• " + modelData
                                    color: Theme.subtext
                                }
                            }
                            Txt {
                                visible: tile.titles.length === 0
                                text: "empty"
                                color: Theme.border
                            }
                            Txt {
                                visible: tile.titles.length > 4
                                text: "+" + (tile.titles.length - 4) + " more"
                                color: Theme.subtext
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                UIState.closeAll();
                                // Lua expression, as Hyprland >= 0.55 requires.
                                Hyprland.dispatch("hl.dsp.focus({ workspace = " + tile.wsId + " })");
                            }
                        }
                    }
                }
            }
        }
    }
}
