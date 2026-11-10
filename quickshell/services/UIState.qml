pragma Singleton
// Which overlay is open. Only one is open at a time. Keybindings reach this
// through `qs ipc call <target> <function>` (see shell.qml); bar buttons call
// toggle() directly.
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool launcher: false
    property bool calendar: false
    property bool wifi: false
    property bool bluetooth: false
    property bool audio: false
    property bool monitor: false
    property bool battery: false
    property bool notificationCenter: false
    property bool overview: false
    property bool power: false
    property string launcherMode: "apps"   // apps | clipboard | wallpapers

    function closeAll() {
        launcher = false;
        calendar = false;
        wifi = false;
        bluetooth = false;
        audio = false;
        monitor = false;
        battery = false;
        notificationCenter = false;
        overview = false;
        power = false;
    }

    function toggle(name) {
        const wasOpen = root[name];
        closeAll();
        root[name] = !wasOpen;
    }

    function openLauncher(mode) {
        closeAll();
        launcherMode = mode;
        launcher = true;
    }
}
