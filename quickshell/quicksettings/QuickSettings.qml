// GNOME-style quick settings (SUPER+A or click the status icons).
//
// Tiles show real state and grey out when a feature is missing: no Bluetooth
// adapter, no Wi-Fi hardware, no hyprsunset, no backlight (typical in a VM).
// Nothing here runs privileged commands; Wi-Fi uses nmcli (NetworkManager
// asks polkit if needed) and Bluetooth goes through BlueZ over D-Bus.
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

        open: UIState.quickSettings
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property var connectedBt: Array.from(Bluetooth.devices.values).filter(d => d.connected).map(d => d.name)

        onOpenChanged: {
            if (!open) return;
            Network.refresh();
            Brightness.refresh();
        }

        Card {
            anchors.right: parent.right
            anchors.rightMargin: 10
            y: Config.barHeight + 8
            width: 380
            height: content.implicitHeight + 32
            opacity: win.progress
            scale: 0.97 + 0.03 * win.progress
            transformOrigin: Item.TopRight

            MouseArea { anchors.fill: parent }

            Column {
                id: content
                x: 16
                y: 16
                width: parent.width - 32
                spacing: 14

                Grid {
                    columns: 2
                    spacing: 10

                    ToggleTile {
                        width: 169
                        glyph: Icons.wifi
                        title: "Wi-Fi"
                        subtitle: !Network.wifiAvailable ? "No adapter"
                                : Network.kind === "wifi" ? Network.name
                                : (Network.wifiEnabled ? "Not connected" : "Off")
                        active: Network.wifiEnabled
                        usable: Network.wifiAvailable
                        onClicked: Network.setWifi(!Network.wifiEnabled)
                    }

                    ToggleTile {
                        width: 169
                        glyph: Icons.bluetooth
                        title: "Bluetooth"
                        subtitle: win.adapter === null ? "No adapter"
                                : !win.adapter.enabled ? "Off"
                                : win.connectedBt.length > 0 ? win.connectedBt[0] : "On"
                        active: win.adapter !== null && win.adapter.enabled
                        usable: win.adapter !== null
                        onClicked: win.adapter.enabled = !win.adapter.enabled
                    }

                    ToggleTile {
                        width: 169
                        glyph: Theme.dark ? Icons.moon : Icons.sun
                        title: "Dark style"
                        subtitle: Theme.dark ? "Dark" : "Light"
                        active: Theme.dark
                        onClicked: Theme.setDark(!Theme.dark)
                    }

                    ToggleTile {
                        width: 169
                        glyph: Icons.sun
                        title: "Night light"
                        subtitle: !NightLight.available ? "Not installed" : (NightLight.enabled ? "On" : "Off")
                        active: NightLight.enabled
                        usable: NightLight.available
                        onClicked: NightLight.toggle()
                    }

                    ToggleTile {
                        width: 169
                        glyph: Notifs.dnd ? Icons.bellOff : Icons.bell
                        title: "Do not disturb"
                        subtitle: Notifs.dnd ? "On" : "Off"
                        active: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }

                    ToggleTile {
                        width: 169
                        glyph: Audio.micMuted ? Icons.micOff : Icons.mic
                        title: "Microphone"
                        subtitle: !Audio.micAvailable ? "No input" : (Audio.micMuted ? "Muted" : "On")
                        active: Audio.micMuted
                        usable: Audio.micAvailable
                        onClicked: Audio.toggleMic()
                    }
                }

                // Volume
                Row {
                    spacing: 12

                    BarButton {
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: Audio.toggleMute()
                        Txt {
                            width: 20
                            horizontalAlignment: Text.AlignHCenter
                            text: (Audio.muted || Audio.volume === 0) ? Icons.volumeOff : Icons.volumeHigh
                            font.pixelSize: 16
                            color: Audio.muted ? Theme.red : Theme.text
                        }
                    }
                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: content.width - 120
                        value: Audio.volume
                        maximum: 1.0
                        onMoved: v => Audio.setVolume(v)
                    }
                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(Audio.volume * 100) + "%"
                    }
                }

                // Brightness: only where a backlight exists.
                Row {
                    visible: Brightness.available
                    spacing: 12

                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        horizontalAlignment: Text.AlignHCenter
                        text: Icons.sun
                        font.pixelSize: 16
                    }
                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: content.width - 120
                        value: Brightness.level
                        maximum: 1.0
                        onMoved: v => Brightness.setLevel(v)
                    }
                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(Brightness.level * 100) + "%"
                    }
                }

                // Status lines
                Column {
                    spacing: 6

                    Txt {
                        text: Network.connected
                            ? "Network: " + Network.name + " (" + (Network.kind === "wifi" ? "Wi-Fi" : "wired") + ")"
                            : "Network: offline"
                        color: Theme.subtext
                    }
                    Txt {
                        visible: Battery.present
                        text: "Battery: " + Battery.percent + "%" + (Battery.charging ? ", charging" : ", on battery")
                        color: Battery.low ? Theme.red : Theme.subtext
                    }
                }
            }
        }
    }
}
