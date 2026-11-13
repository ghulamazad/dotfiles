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
// Also here: live stats (ping, loss, speed, totals), the DNS provider switch,
// a download speed test, and the join-QR code. Stats poll only while a panel
// asks for them (`statsActive`).
//
// Limits (not handled): enterprise Wi-Fi (802.1X), hidden networks, WEP.
// UNTESTED at runtime: needs a real Wi-Fi adapter, which a VM usually lacks.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

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

    // Active connection details
    property string device: ""        // e.g. wlan0
    property string ipAddress: "-"
    property string gateway: "-"
    property string dnsMode: "dhcp"   // dhcp | cloudflare | google | custom
    property string dnsCustom: ""     // what a custom profile currently holds
    property bool dnsBusy: false
    property string dnsMessage: ""

    // Live stats (only updated while statsActive is true)
    property bool statsActive: false
    property real rxRate: 0           // bytes/s
    property real txRate: 0
    property real rxTotal: 0          // bytes since the interface came up
    property real txTotal: 0
    property real pingMs: -1          // -1 = unknown
    property real lossPct: -1

    // Speed test (download only) and QR code
    property bool speedRunning: false
    property real speedMbps: -1
    property string speedMessage: ""
    property string qrPath: ""
    property string qrMessage: ""

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
        let k = "none", n = "", dev = "", wifi = false;
        for (const line of txt.split("\n")) {
            if (!line) continue;
            const f = splitTerse(line);        // DEVICE:TYPE:STATE:CONNECTION
            if (f.length < 4) continue;
            if (f[1] === "wifi") wifi = true;
            if ((f[1] === "wifi" || f[1] === "ethernet") && f[2].startsWith("connected") && k === "none") {
                k = f[1];
                n = f[3];
                dev = f[0];
            }
        }
        kind = k;
        name = n;
        wifiAvailable = wifi;
        if (dev !== device) {
            device = dev;
            lastRx = -1;
            if (dev !== "") detailsProc.running = true;
        }
        if (n === "") { ipAddress = "-"; gateway = "-"; }
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
            net.group = net.known || net.inUse ? "KNOWN NETWORKS" : "OTHER NETWORKS";
            const old = best[net.ssid];
            if (!old || net.inUse || (!old.inUse && net.signal > old.signal)) best[net.ssid] = net;
        }
        networks = Object.values(best).sort((a, b) =>
            (a.group === b.group ? 0 : (a.group === "KNOWN NETWORKS" ? -1 : 1))
            || (b.inUse - a.inUse) || (b.signal - a.signal));
    }


    // ---- details, stats, DNS, speed test, QR ------------------------------
    property real lastRx: -1
    property real lastTx: 0
    property real lastAt: 0

    readonly property var dnsPresets: ({
        cloudflare: { v4: ["1.1.1.1", "1.0.0.1"], v6: ["2606:4700:4700::1111", "2606:4700:4700::1001"] },
        google:     { v4: ["8.8.8.8", "8.8.4.4"], v6: ["2001:4860:4860::8888", "2001:4860:4860::8844"] }
    })

    // Interface names reach a /sys path, so accept plain names only.
    function safeDevice(d) { return /^[A-Za-z0-9_-][A-Za-z0-9_.-]*$/.test(d) && d.indexOf("..") < 0; }
    function isIPv4(s) {
        const m = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec(s);
        return m !== null && m.slice(1).every(o => parseInt(o) <= 255);
    }
    function isIPv6(s) { return /^[0-9A-Fa-f:]{2,39}$/.test(s) && (s.match(/:/g) || []).length >= 2; }

    function fmtBytes(b) {
        if (b < 0) return "-";
        const u = ["B", "KB", "MB", "GB", "TB"];
        let i = 0;
        while (b >= 1000 && i < u.length - 1) { b /= 1000; i++; }
        return (i === 0 ? Math.round(b) : b.toFixed(2)) + " " + u[i];
    }
    function fmtRate(b) { return fmtBytes(b) + "/s"; }

    function parseDetails(txt) {
        let ip = "-", gw = "-";
        for (const line of txt.split("\n")) {
            const i = line.indexOf(":");
            if (i < 0) continue;
            const k = line.slice(0, i), v = line.slice(i + 1).trim();
            if (k.indexOf("IP4.ADDRESS") === 0 && ip === "-") ip = v.split("/")[0];
            if (k === "IP4.GATEWAY" && v !== "" && v !== "--") gw = v;
        }
        ipAddress = ip;
        gateway = gw;
    }

    function parseDnsProfile(txt) {
        const lines = txt.split("\n");
        const list = (lines[0] || "").split(/[,\s]+/).filter(s => s !== "");
        const ignoreAuto = (lines[1] || "").trim() === "yes";
        dnsCustom = list.join(" ");
        if (!ignoreAuto || list.length === 0) { dnsMode = "dhcp"; return; }
        const same = (a, b) => a.length === b.length && a.every(x => b.indexOf(x) >= 0);
        const v4 = list.filter(isIPv4);
        if (same(v4, dnsPresets.cloudflare.v4)) dnsMode = "cloudflare";
        else if (same(v4, dnsPresets.google.v4)) dnsMode = "google";
        else dnsMode = "custom";
    }

    function readDns() {
        if (name === "") return;
        dnsProc.command = ["nmcli", "-t", "-g", "ipv4.dns,ipv4.ignore-auto-dns", "connection", "show", "id", name];
        dnsProc.running = true;
    }

    // mode: dhcp | cloudflare | google | custom (custom: space/comma separated addresses)
    function setDns(mode, custom) {
        if (dnsBusy || name === "") return;
        dnsMessage = "";
        let v4 = [], v6 = [];
        if (mode === "custom") {
            const items = (custom || "").split(/[,\s]+/).filter(s => s !== "");
            if (items.length === 0 || items.length > 4) { dnsMessage = "Enter 1 to 4 DNS addresses."; return; }
            for (const a of items) {
                if (isIPv4(a)) v4.push(a);
                else if (isIPv6(a)) v6.push(a);
                else { dnsMessage = "Not a valid IP address: " + a; return; }
            }
        } else if (mode !== "dhcp") {
            v4 = dnsPresets[mode].v4;
            v6 = dnsPresets[mode].v6;
        }
        const manual = mode !== "dhcp";
        dnsBusy = true;
        // Fixed argument list: every value is a separate argv element.
        dnsModProc.command = ["nmcli", "connection", "modify", "id", name,
            "ipv4.dns", v4.join(","), "ipv4.ignore-auto-dns", (manual && v4.length > 0) ? "yes" : "no",
            "ipv6.dns", v6.join(","), "ipv6.ignore-auto-dns", (manual && v6.length > 0) ? "yes" : "no"];
        dnsModProc.running = true;
    }

    function runSpeedTest() {
        if (speedRunning || kind === "none") return;
        speedRunning = true;
        speedMbps = -1;
        speedMessage = "";
        // One 25 MB download from Cloudflare's public speed-test endpoint.
        speedProc.running = true;
    }

    function showQr() {
        if (kind !== "wifi" || name === "") return;
        qrMessage = "";
        qrPath = "";
        qrProc.command = [Config.scriptsDir + "/wifi-qr.sh", "make", name];
        qrProc.running = true;
    }

    function clearQr() {
        qrPath = "";
        qrMessage = "";
        Quickshell.execDetached([Config.scriptsDir + "/wifi-qr.sh", "clear"]);
    }

    function pollStats() {
        if (device === "" || !safeDevice(device)) return;
        const base = "/sys/class/net/" + device + "/statistics/";
        rateProc.command = ["cat", base + "rx_bytes", base + "tx_bytes"];
        rateProc.running = true;
    }

    function pollPing() {
        if (!isIPv4(gateway) || pingProc.running) return;
        pingProc.command = ["ping", "-c", "4", "-i", "0.25", "-W", "1", "-q", gateway];
        pingProc.running = true;
    }

    onStatsActiveChanged: {
        if (statsActive) {
            lastRx = -1;
            pingMs = -1;
            lossPct = -1;
            refresh();
            readDns();
            pollStats();
            pollPing();
        }
    }
    onNameChanged: readDns()

    Timer { interval: 1000; running: root.statsActive; repeat: true; onTriggered: root.pollStats() }
    Timer { interval: 6000; running: root.statsActive; repeat: true; onTriggered: root.pollPing() }

    Process {
        id: detailsProc
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS,IP4.GATEWAY", "device", "show", root.device]
        stdout: StdioCollector { onStreamFinished: root.parseDetails(text) }
    }

    Process {
        id: dnsProc
        stdout: StdioCollector { onStreamFinished: root.parseDnsProfile(text) }
    }

    // Step 1 of a DNS change: edit the profile. Step 2: re-apply it live.
    Process {
        id: dnsModProc
        onExited: code => {
            if (code !== 0) {
                root.dnsBusy = false;
                root.dnsMessage = "Could not change DNS (permission denied or invalid value).";
                return;
            }
            reapplyProc.command = ["nmcli", "device", "reapply", root.device];
            reapplyProc.running = true;
        }
    }
    Process {
        id: reapplyProc
        onExited: code => {
            root.dnsBusy = false;
            if (code !== 0) root.dnsMessage = "Saved, but not applied yet: reconnect to use it.";
            root.readDns();
            root.refresh();
        }
    }

    // rx_bytes and tx_bytes, one per line.
    Process {
        id: rateProc
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim().split("\n").map(Number);
                if (v.length < 2 || isNaN(v[0]) || isNaN(v[1])) return;
                const now = Date.now();
                if (root.lastRx >= 0 && now > root.lastAt) {
                    const dt = (now - root.lastAt) / 1000;
                    root.rxRate = Math.max(0, (v[0] - root.lastRx) / dt);
                    root.txRate = Math.max(0, (v[1] - root.lastTx) / dt);
                }
                root.lastRx = v[0]; root.lastTx = v[1]; root.lastAt = now;
                root.rxTotal = v[0]; root.txTotal = v[1];
            }
        }
    }

    // Ping the gateway (the router), not a third party: it measures this link.
    Process {
        id: pingProc
        stdout: StdioCollector {
            onStreamFinished: {
                const loss = /([\d.]+)% packet loss/.exec(text);
                const rtt = /= [\d.]+\/([\d.]+)\//.exec(text);
                root.lossPct = loss ? parseFloat(loss[1]) : -1;
                root.pingMs = rtt ? parseFloat(rtt[1]) : -1;
            }
        }
        onExited: code => { if (code !== 0 && code !== 1) { root.pingMs = -1; root.lossPct = -1; } }
    }

    Process {
        id: speedProc
        command: ["curl", "-sS", "-o", "/dev/null", "--max-time", "20",
                  "-w", "%{speed_download}", "https://speed.cloudflare.com/__down?bytes=25000000"]
        stdout: StdioCollector {
            onStreamFinished: {
                const bps = parseFloat(text);
                if (!isNaN(bps) && bps > 0) root.speedMbps = bps * 8 / 1e6;
            }
        }
        onExited: code => {
            root.speedRunning = false;
            if (root.speedMbps < 0) root.speedMessage = "Speed test failed (offline or blocked).";
        }
    }

    Process {
        id: qrProc
        stdout: StdioCollector { onStreamFinished: root.qrPath = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim() !== "") root.qrMessage = text.trim() }
        onExited: code => { if (code !== 0 && root.qrMessage === "") root.qrMessage = "Could not make the QR code."; }
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
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
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
