// Monitor: brightness only. In a VM there is normally no backlight, and the
// panel says so instead of showing a slider that does nothing.
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

        open: UIState.monitor
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        onOpenChanged: if (open) Brightness.refresh()

        PanelFrame {
            progress: win.progress
            cardWidth: 320

            PanelHeader { title: "Display" }

            Txt {
                width: parent.width
                visible: !Brightness.available
                wrapMode: Text.WordWrap
                text: "No controllable backlight found (normal in a virtual machine or on an external monitor)."
                color: Theme.subtext
            }

            Row {
                width: parent.width
                spacing: 10
                visible: Brightness.available

                Txt { width: 24; horizontalAlignment: Text.AlignHCenter; text: Icons.sun; font.pixelSize: 16 }
                Slider {
                    width: parent.width - 24 - 44 - 20
                    anchors.verticalCenter: parent.verticalCenter
                    value: Brightness.level
                    onMoved: v => Brightness.setLevel(v)
                }
                Txt {
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(Brightness.level * 100) + "%"
                    color: Theme.subtext
                }
            }
        }
    }
}
