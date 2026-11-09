pragma Singleton
// Display brightness through `brightnessctl` (the same tool the hardware keys
// in hypr/keybindings.lua use). `available` stays false when no backlight
// device exists, as in most VMs, and the UI hides the slider.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property real level: 0   // 0.0 to 1.0

    function refresh() { query.running = true; }

    function setLevel(value) {
        const percent = Math.round(Math.max(0.01, Math.min(1, value)) * 100);
        level = percent / 100;
        Quickshell.execDetached(["brightnessctl", "set", percent + "%"]);
    }

    Component.onCompleted: refresh()

    // `brightnessctl -m` prints: device,class,current,percent%,max
    Process {
        id: query
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                const p = f.length >= 5 ? parseInt(f[3]) : NaN;
                root.available = !isNaN(p);
                if (root.available) root.level = p / 100;
            }
        }
    }
}
