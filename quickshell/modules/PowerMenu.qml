// Power menu (SUPER+SHIFT+E or the bar's power button).
// Logging out, rebooting and powering off need a second click to confirm.
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

        open: UIState.power
        layerNamespace: "qs-power"
        onCloseRequested: UIState.closeAll()

        property string armed: ""
        onOpenChanged: { if (!open) armed = ""; }

        Card {
            anchors.centerIn: parent
            width: row.implicitWidth + 48
            height: 190
            opacity: win.progress
            scale: 0.96 + 0.04 * win.progress

            MouseArea { anchors.fill: parent }   // clicks inside must not close

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 14

                Repeater {
                    model: PowerActions.actions

                    delegate: Rectangle {
                        id: tile
                        required property var modelData

                        readonly property bool armedNow: win.armed === modelData.id

                        width: 104
                        height: 104
                        radius: Config.radius
                        color: armedNow ? Theme.red : (mouse.containsMouse ? Theme.surface2 : Theme.surface)

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Txt {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: tile.modelData.glyph
                                font.pixelSize: 28
                                color: tile.armedNow ? Theme.bg : Theme.text
                            }
                            Txt {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: tile.armedNow ? "Confirm?" : tile.modelData.name
                                color: tile.armedNow ? Theme.bg : Theme.text
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (tile.modelData.confirm && win.armed !== tile.modelData.id) {
                                    win.armed = tile.modelData.id;
                                    return;
                                }
                                UIState.closeAll();
                                PowerActions.run(tile.modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
