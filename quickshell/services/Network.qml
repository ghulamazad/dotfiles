pragma Singleton
// Network status through NetworkManager's `nmcli`. No root needed: nmcli talks
// to NetworkManager over D-Bus and NetworkManager asks polkit if an action
// needs authorization. Every command below is a fixed argument list; nothing
// user-controlled is ever passed to a shell.
//
// Limitation: this shows status and toggles Wi-Fi. It does not list networks
// or ask for passwords. Use `nm-connection-editor` (package network-manager-
// applet) or `nmcli` for that.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string kind: "none"     // wifi | ethernet | none
    property string name: ""
    property bool wifiAvailable: false
    property bool wifiEnabled: false
    readonly property bool connected: kind !== "none"

    function refresh() {
        statusProc.running = true;
        radioProc.running = true;
    }

    function setWifi(on) {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        settle.restart();
    }

    // `nmcli -t` escapes literal colons as "\:"; protect them while splitting.
    function parseStatus(txt) {
        let k = "none", n = "", wifi = false;
        for (const line of txt.split("\n")) {
            if (!line) continue;
            const f = line.replace(/\\:/g, "\u0001").split(":").map(s => s.replace(/\u0001/g, ":"));
            if (f.length < 3) continue;
            if (f[0] === "wifi") wifi = true;
            if ((f[0] === "wifi" || f[0] === "ethernet") && f[1].startsWith("connected") && k === "none") {
                k = f[0];
                n = f[2];
            }
        }
        kind = k;
        name = n;
        wifiAvailable = wifi;
    }

    Timer { id: settle; interval: 800; onTriggered: root.refresh() }
    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: root.wifiEnabled = (text.trim() === "enabled") }
    }
}
