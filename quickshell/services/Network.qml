pragma Singleton
// Network status, Wi-Fi list and connecting, all through NetworkManager's
// `nmcli`. No root needed: nmcli talks to NetworkManager over D-Bus and
// NetworkManager asks polkit when an action needs authorization.
//
// Safety: every command is a fixed argument list. Nothing is passed to a shell
// except one constant script (see `writer`). A Wi-Fi password is NEVER put on a
// command line, where other processes could read it. It travels over stdin
// into a private file that nmcli reads with `passwd-file` (documented in the
// nmcli man page), and that file is deleted right after.
//
// Limits (not handled): enterprise Wi-Fi (802.1X), hidden networks, WEP.
// UNTESTED at runtime: needs a real Wi-Fi adapter, which a VM usually lacks.
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

    // Scan results: { ssid, signal (0-100), security, inUse, known }
    property var networks: []
    property var knownProfiles: []
    property bool scanning: false
    property bool busy: false
    property string message: ""

    function refresh() {
        statusProc.running = true;
        radioProc.running = true;
    }

    function setWifi(on) {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        settle.restart();
    }

    function scan() {
        if (scanning) return;
        scanning = true;
        knownProc.running = true;
        listProc.running = true;
    }

    // Connect to a network from the list. `password` is only used for a secured
    // network that has no saved profile yet.
    function connect(net, password) {
        if (busy) return;
        message = "";
        busy = true;
        current = net;
        if (net.known) {
            upProc.command = ["nmcli", "--wait", "25", "connection", "up", "id", net.ssid];
            upProc.running = true;
        } else if (!net.secure) {
            openProc.command = ["nmcli", "--wait", "25", "device", "wifi", "connect", net.ssid];
            openProc.running = true;
        } else if (net.enterprise) {
            fail("Enterprise Wi-Fi is not supported here. Use nmtui.");
        } else if (!password || password.length < 8) {
            fail("Password too short (WPA needs at least 8 characters).");
        } else {
            pendingPassword = password;
            addProc.command = ["nmcli", "connection", "add", "type", "wifi", "con-name", net.ssid,
                               "ssid", net.ssid, "wifi-sec.key-mgmt", net.sae ? "sae" : "wpa-psk"];
            addProc.running = true;
        }
    }

    function disconnectNetwork(ssid) {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", ssid]);
        settle.restart();
    }

    // ---- internals
    property var current: null
    property string pendingPassword: ""
    readonly property string secretFile: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/qs-wifi-secret"

    function fail(text) {
        message = text;
        busy = false;
        pendingPassword = "";
        scan();
    }

    function done() {
        busy = false;
        message = "";
        pendingPassword = "";
        refresh();
        scan();
    }

    // `nmcli -t` escapes literal colons as "\:"; protect them while splitting.
    function splitTerse(line) {
        return line.replace(/\\\\/g, "\u0002").replace(/\\:/g, "\u0001").split(":")
            .map(s => s.replace(/\u0001/g, ":").replace(/\u0002/g, "\\"));
    }

    function parseStatus(txt) {
        let k = "none", n = "", wifi = false;
        for (const line of txt.split("\n")) {
            if (!line) continue;
            const f = splitTerse(line);
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

    function parseKnown(txt) {
        const out = [];
        for (const line of txt.split("\n")) {
            const f = splitTerse(line);
            if (f.length >= 2 && f[1] === "802-11-wireless") out.push(f[0]);
        }
        knownProfiles = out;
    }

    function parseList(txt) {
        const best = {};
        for (const line of txt.split("\n")) {
            if (!line) continue;
            const f = splitTerse(line);
            if (f.length < 4 || f[1] === "") continue;
            const sec = f[3] === "--" ? "" : f[3];
            const net = {
                ssid: f[1],
                signal: parseInt(f[2]) || 0,
                security: sec,
                secure: sec !== "",
                enterprise: sec.indexOf("802.1X") >= 0,
                sae: sec.indexOf("WPA3") >= 0 || sec.indexOf("SAE") >= 0,
                inUse: f[0] === "*",
                known: knownProfiles.indexOf(f[1]) >= 0
            };
            const old = best[net.ssid];
            if (!old || net.inUse || (!old.inUse && net.signal > old.signal)) best[net.ssid] = net;
        }
        networks = Object.values(best).sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal));
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

    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector { onStreamFinished: root.parseKnown(text) }
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "auto"]
        stdout: StdioCollector { onStreamFinished: { root.parseList(text); root.scanning = false; } }
        onExited: code => { if (code !== 0) root.scanning = false; }
    }

    // Known profile: bring it up (NetworkManager already holds the secret).
    Process {
        id: upProc
        onExited: code => code === 0 ? root.done() : root.fail("Could not connect to " + root.current.ssid)
    }

    // Open network: no secret involved.
    Process {
        id: openProc
        onExited: code => code === 0 ? root.done() : root.fail("Could not connect to " + root.current.ssid)
    }

    // Secured, new network, step 1: create the profile without a password.
    Process {
        id: addProc
        onExited: code => {
            if (code !== 0) { root.fail("Could not create a profile for " + root.current.ssid); return; }
            writer.running = true;
        }
    }

    // Step 2: write "setting.property:secret" into a 0600 file, through stdin.
    // The script is constant; the path is a positional argument, never spliced in.
    Process {
        id: writer
        command: ["sh", "-c", "umask 077; cat > \"$1\"", "sh", root.secretFile]
        stdinEnabled: true
        onRunningChanged: {
            if (running) {
                write("802-11-wireless-security." + (root.current.sae ? "sae-password" : "psk") + ":" + root.pendingPassword + "\n");
                stdinEnabled = false;   // closes stdin so cat finishes
            }
        }
        onExited: code => {
            root.pendingPassword = "";
            if (code !== 0) { root.fail("Could not store the password temporarily."); return; }
            secretUp.command = ["nmcli", "--wait", "25", "connection", "up", "id", root.current.ssid,
                                "passwd-file", root.secretFile];
            secretUp.running = true;
        }
    }

    // Step 3: activate with the secret file, then always delete it.
    Process {
        id: secretUp
        onExited: code => {
            wipe.running = true;
            if (code === 0) {
                root.done();
            } else {
                // Remove the half-made profile so a wrong password is not saved.
                Quickshell.execDetached(["nmcli", "connection", "delete", "id", root.current.ssid]);
                root.fail("Could not connect. Wrong password?");
            }
        }
    }

    Process {
        id: wipe
        command: ["rm", "-f", root.secretFile]
    }
}
