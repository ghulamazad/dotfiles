pragma Singleton
// Which shell surface is open. Hyprland keybindings reach this through the
// IpcHandlers in shell.qml.
import QtQuick
import Quickshell

Singleton {
    property bool launcher: false
    property bool wifi: false
    property bool bluetooth: false
    property string panel: ""              // sound, system, battery, clock or tray
    property string launcherMode: "apps"   // apps or power
    property bool barVisible: true

    function closeAll() { launcher = false; wifi = false; bluetooth = false; panel = ""; }

    function togglePanel(name) {
        const next = panel !== name;
        closeAll();
        if (next) panel = name;
    }

    function openLauncher(mode) {
        wifi = false;
        bluetooth = false;
        panel = "";
        launcherMode = mode;
        launcher = true;
    }

    function toggleWifi() {
        const next = !wifi;
        closeAll();
        wifi = next;
    }

    function toggleBluetooth() {
        const next = !bluetooth;
        closeAll();
        bluetooth = next;
    }

    function toggleLauncher(mode) {
        if (launcher && launcherMode === mode) closeAll();
        else openLauncher(mode);
    }
}
