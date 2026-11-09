pragma Singleton
// Night light through `hyprsunset`, if installed. The tile is greyed out when
// it is not, so nothing pretends to work.
//
// UNVERIFIED: I could not check the hyprsunset package name or its -t option
// against current documentation. If the toggle does nothing, run
// `hyprsunset --help` and adjust `command` below.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property bool enabled: false
    property int kelvin: 4500

    function toggle() {
        if (available) enabled = !enabled;
    }

    Component.onCompleted: detect.running = true

    Process {
        id: detect
        command: ["sh", "-c", "command -v hyprsunset"]
        onExited: exitCode => root.available = (exitCode === 0)
    }

    // Running the process applies the filter; stopping it (SIGTERM) removes it.
    Process {
        id: worker
        command: ["hyprsunset", "-t", String(root.kelvin)]
        running: root.available && root.enabled
    }
}
