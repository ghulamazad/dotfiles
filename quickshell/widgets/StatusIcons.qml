// Status icons: Bluetooth, network, sound, display, battery. Each is its own
// button and opens the matching panel.
import QtQuick
import Quickshell.Bluetooth
import qs.components
import qs.services
import qs.themes

Row {
    spacing: 4
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter !== null && adapter.enabled
    readonly property bool btConnected: Array.from(Bluetooth.devices.values).some(d => d.connected)

    BarButton {
        visible: adapter !== null
        active: UIState.bluetooth
        onClicked: UIState.toggle("bluetooth")
        Txt {
            text: Icons.bluetooth
            font.pixelSize: 15
            color: btConnected ? Theme.accent : (btOn ? Theme.text : Theme.subtext)
        }
    }

    BarButton {
        active: UIState.wifi
        onClicked: UIState.toggle("wifi")
        Txt {
            text: Network.kind === "wifi" ? Icons.wifi : Icons.wired
            font.pixelSize: 15
            color: Network.connected ? Theme.text : Theme.red
        }
    }

    BarButton {
        active: UIState.audio
        onClicked: UIState.toggle("audio")
        Txt {
            text: (Audio.muted || Audio.volume === 0) ? Icons.volumeOff
                : Audio.volume < 0.5 ? Icons.volumeLow : Icons.volumeHigh
            font.pixelSize: 15
            color: Audio.muted ? Theme.red : Theme.text
        }
    }

    BarButton {
        active: UIState.monitor
        onClicked: UIState.toggle("monitor")
        Txt { text: Icons.desktop; font.pixelSize: 15 }
    }

    BarButton {
        visible: Battery.present
        active: UIState.battery
        onClicked: UIState.toggle("battery")
        Txt {
            text: Battery.charging ? Icons.bolt : Icons.battery(Battery.fraction)
            font.pixelSize: 15
            color: Battery.low ? Theme.red : (Battery.charging ? Theme.green : Theme.text)
        }
        Txt { text: Battery.percent + "%" }
    }
}
