// Bluetooth: on/off, scan, connect/disconnect, pair. Pairing that needs a PIN
// or confirmation is NOT handled here (no agent): use `bluetoothctl` for that.
// UNTESTED at runtime: a VM normally has no Bluetooth adapter.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Bluetooth
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

        open: UIState.bluetooth
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        readonly property var adapter: Bluetooth.defaultAdapter

        // Do not leave discovery running (it drains battery) once the panel closes.
        onOpenChanged: if (!open && adapter && adapter.discovering) adapter.discovering = false

        PanelFrame {
            progress: win.progress

            PanelHeader {
                title: "Bluetooth"
                BarButton {
                    visible: win.adapter !== null && win.adapter.enabled
                    active: win.adapter !== null && win.adapter.discovering
                    onClicked: win.adapter.discovering = !win.adapter.discovering
                    Txt { text: (win.adapter && win.adapter.discovering) ? "Scanning…" : "Scan"; color: Theme.subtext }
                }
                BarButton {
                    visible: win.adapter !== null
                    active: win.adapter !== null && win.adapter.enabled
                    onClicked: win.adapter.enabled = !win.adapter.enabled
                    Txt { text: (win.adapter && win.adapter.enabled) ? "On" : "Off" }
                }
            }

            Txt {
                width: parent.width
                visible: win.adapter === null
                wrapMode: Text.WordWrap
                text: "No Bluetooth adapter found."
                color: Theme.subtext
            }

            Txt {
                width: parent.width
                visible: win.adapter !== null && !win.adapter.enabled
                text: "Bluetooth is off."
                color: Theme.subtext
            }

            ListView {
                width: parent.width
                height: Math.min(contentHeight, 272)
                visible: win.adapter !== null && win.adapter.enabled
                clip: true
                spacing: 2
                model: Bluetooth.devices

                delegate: ListRow {
                    id: row
                    required property var modelData
                    glyph: Icons.bluetooth
                    glyphColor: modelData.connected ? Theme.accent : Theme.text
                    title: modelData.name
                    subtitle: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Not paired")
                    trailing: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                    highlighted: modelData.connected
                    onClicked: {
                        if (modelData.connected) modelData.disconnect();
                        else if (modelData.paired) modelData.connect();
                        else modelData.pair();
                    }
                }
            }

            Txt {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Pairing that asks for a PIN: use bluetoothctl."
                color: Theme.subtext
                font.pixelSize: Config.fontSize - 2
            }
        }
    }
}
