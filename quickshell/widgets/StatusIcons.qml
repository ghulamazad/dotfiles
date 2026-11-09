// Network, Bluetooth, audio and battery status in one button.
// Click opens quick settings.
import QtQuick
import Quickshell.Bluetooth
import qs.components
import qs.services
import qs.themes

BarButton {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter !== null && adapter.enabled
    readonly property bool btConnected: Array.from(Bluetooth.devices.values).some(d => d.connected)

    onClicked: UIState.toggle("quickSettings")

    Txt {
        text: Network.kind === "wifi" ? Icons.wifi : Icons.wired
        font.pixelSize: 15
        color: Network.connected ? Theme.text : Theme.red
    }

    Txt {
        visible: adapter !== null
        text: Icons.bluetooth
        font.pixelSize: 15
        color: btConnected ? Theme.accent : (btOn ? Theme.text : Theme.subtext)
    }

    Txt {
        text: (Audio.muted || Audio.volume === 0) ? Icons.volumeOff
            : Audio.volume < 0.5 ? Icons.volumeLow : Icons.volumeHigh
        font.pixelSize: 15
        color: Audio.muted ? Theme.red : Theme.text
    }

    Txt {
        visible: Battery.present
        text: Battery.charging ? Icons.bolt : Icons.battery(Battery.fraction)
        font.pixelSize: 15
        color: Battery.low ? Theme.red : (Battery.charging ? Theme.green : Theme.text)
    }
    Txt {
        visible: Battery.present
        text: Battery.percent + "%"
    }
}
