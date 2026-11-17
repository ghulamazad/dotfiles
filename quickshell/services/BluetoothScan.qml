pragma Singleton
// Bluetooth device discovery for the Bluetooth panel, kept in one place.
//
// The BlueZ discovery session behind `adapter.discovering` belongs to
// Quickshell's D-Bus connection, so nothing ends it by itself: a scan left
// running keeps the radio in inquiry and makes Bluetooth audio stutter. So:
//  * while the panel is open and scanning is wanted, retry every second (BlueZ
//    refuses a start while the adapter is still powering up, and scans can time out);
//  * after it closes, stop the scan, driven by the state BlueZ reports (a stop
//    written while a start is still unconfirmed is swallowed), with bounded tries;
//  * only a scan this service started is ever stopped.
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    property bool active: false          // the panel is open
    property bool wanted: true           // false after you pause scanning from the panel
    property bool owesStop: false        // we started a scan and must stop it

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool scanning: adapter !== null && adapter.discovering

    function toggle() { wanted = !wanted; }

    onActiveChanged: if (active) wanted = true

    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.active && root.wanted && root.adapter !== null && root.adapter.enabled && !root.adapter.discovering
        onTriggered: {
            root.owesStop = true;
            root.adapter.discovering = true;
        }
    }

    Timer {
        id: stopper
        interval: 1000
        repeat: true
        property int attempts: 0
        running: (!root.active || !root.wanted) && root.owesStop && root.adapter !== null && root.adapter.discovering
        onRunningChanged: if (running) attempts = 0
        onTriggered: {
            attempts += 1;
            // A session some other client keeps up must not draw StopDiscovery forever.
            if (attempts > 3) { root.owesStop = false; return; }
            root.adapter.discovering = false;
        }
    }

    // The debt is settled once BlueZ reports discovery down, however it ended.
    Connections {
        target: root.adapter
        function onDiscoveringChanged() {
            if (root.adapter !== null && !root.adapter.discovering) root.owesStop = false;
        }
    }
}
