pragma Singleton
// Network STATUS only (for the bar icon): which kind of link is up and its name.
// Read-only: this never changes a connection. Use nmtui or nmcli to manage Wi-Fi.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string kind: "none"     // wifi | ethernet | none
    property string name: ""
    readonly property bool connected: kind !== "none"

    // `nmcli -t` escapes literal colons as "\:"; protect them while splitting.
    function splitTerse(line) {
        return line.replace(/\\\\/g, "\u0002").replace(/\\:/g, "\u0001").split(":")
            .map(s => s.replace(/\u0001/g, ":").replace(/\u0002/g, "\\"));
    }

    function parseStatus(txt) {
        let k = "none", n = "";
        for (const line of txt.split("\n")) {
            if (!line) continue;
            const f = splitTerse(line);        // TYPE:STATE:CONNECTION
            if (f.length < 3) continue;
            if ((f[0] === "wifi" || f[0] === "ethernet") && f[1].startsWith("connected") && k === "none") {
                k = f[0];
                n = f[2];
            }
        }
        kind = k;
        name = n;
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
    }
}
