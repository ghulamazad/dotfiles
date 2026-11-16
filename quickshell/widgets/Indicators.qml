// Status icons at the right of the bar: Bluetooth, network, sound, CPU,
// battery. Icons only. Every one opens a dropdown panel with the same look
// (modules/*Panel.qml); there are no terminal tools behind them.
// Sound: click opens the panel, right-click mutes, scroll changes the volume.
import QtQuick
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

    BarButton {
        visible: root.adapter !== null
        active: UIState.bluetooth
        onClicked: UIState.toggleBluetooth()
        Txt {
            text: root.btConnected ? Icons.bluetoothConnected : (root.btOn ? Icons.bluetooth : Icons.bluetoothOff)
            color: root.btConnected ? Theme.accent : (root.btOn ? Theme.text : Theme.muted)
        }
    }

    BarButton {
        active: UIState.wifi
        onClicked: UIState.toggleWifi()
        Txt {
            text: !Network.connected ? Icons.wifiOff : (Network.kind === "ethernet" ? Icons.wired : Icons.wifi)
            color: Network.connected ? Theme.text : Theme.red
        }
    }

    BarButton {
        active: UIState.panel === "sound"
        onClicked: UIState.togglePanel("sound")
        onRightClicked: Audio.toggleMute()
        onScrolled: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
        Txt {
            text: (Audio.muted || Audio.volume === 0) ? Icons.volumeMuted : Icons.volume(Audio.volume)
            color: Audio.muted ? Theme.red : Theme.text
        }
    }

    BarButton {
        active: UIState.panel === "system"
        onClicked: UIState.togglePanel("system")
        Txt { text: Icons.cpu }
    }

    BarButton {
        visible: Battery.present
        active: UIState.panel === "battery"
        onClicked: UIState.togglePanel("battery")
        Txt {
            text: Battery.charging ? Icons.batteryCharging : (Battery.low ? Icons.batteryAlert : Icons.battery(Battery.fraction))
            color: Battery.low ? Theme.red : (Battery.charging ? Theme.green : Theme.text)
        }
        Txt { text: Battery.percent + "%"; color: Battery.low ? Theme.red : Theme.subtext }
    }
}
