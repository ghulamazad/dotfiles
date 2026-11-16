// Status icons at the right of the bar: Bluetooth, network, sound, CPU,
// battery. Icons only. Network and Bluetooth open their dashboards (right-click:
// the nmtui / bluetui terminal fallback). Sound and CPU open a small floating
// terminal tool (wiremix, btop).
// Sound: click opens wiremix, right-click mutes, scroll changes the volume.
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.config
import qs.services
import qs.themes

Row {
    id: root
    spacing: 0
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter !== null && adapter.enabled
    readonly property bool btConnected: Array.from(Bluetooth.devices.values).some(d => d.connected)

    // Fixed argument list, no shell involved.
    function tui(program) {
        Quickshell.execDetached([Config.terminal, "--class=" + Config.floatClass, "-e", program]);
    }

    BarButton {
        visible: root.adapter !== null
        onClicked: UIState.toggleBluetooth()
        onRightClicked: root.tui("bluetui")
        Txt {
            text: root.btConnected ? Icons.bluetoothConnected : (root.btOn ? Icons.bluetooth : Icons.bluetoothOff)
            color: root.btConnected ? Theme.accent : (root.btOn ? Theme.text : Theme.muted)
        }
    }

    BarButton {
        onClicked: UIState.toggleWifi()
        onRightClicked: root.tui("nmtui")
        Txt {
            text: !Network.connected ? Icons.wifiOff : (Network.kind === "ethernet" ? Icons.wired : Icons.wifi)
            color: Network.connected ? Theme.text : Theme.red
        }
    }

    BarButton {
        onClicked: root.tui("wiremix")
        onRightClicked: Audio.toggleMute()
        onScrolled: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
        Txt {
            text: (Audio.muted || Audio.volume === 0) ? Icons.volumeMuted : Icons.volume(Audio.volume)
            color: Audio.muted ? Theme.red : Theme.text
        }
    }

    BarButton {
        onClicked: root.tui("btop")
        Txt { text: Icons.cpu }
    }

    BarButton {
        visible: Battery.present
        Txt {
            text: Battery.charging ? Icons.batteryCharging : (Battery.low ? Icons.batteryAlert : Icons.battery(Battery.fraction))
            color: Battery.low ? Theme.red : (Battery.charging ? Theme.green : Theme.text)
        }
        Txt { text: Battery.percent + "%"; color: Battery.low ? Theme.red : Theme.subtext }
    }
}
