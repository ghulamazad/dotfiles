pragma Singleton
// Whether the launcher is open. SUPER+Space reaches this through
// `qs ipc call launcher toggle` (see shell.qml).
import QtQuick
import Quickshell

Singleton {
    property bool launcher: false

    function closeAll() { launcher = false; }
    function toggleLauncher() { launcher = !launcher; }
}
