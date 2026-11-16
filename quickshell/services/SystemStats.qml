pragma Singleton
// CPU, memory, load and the busiest processes, for the System panel. It runs
// only while `active` is true (the panel is open): zero background cost
// otherwise. Reads /proc and `ps` with fixed argument lists, no shell.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    property real cpu: 0                 // 0 to 1, since the previous sample
    property real memUsed: 0             // kB
    property real memTotal: 0            // kB
    property string load: ""             // "0.42 0.51 0.60"
    property string uptime: ""
    property var top: []                 // [{ name, cpu }]

    property real lastTotal: 0
    property real lastIdle: 0

    function parse(text) {
        const lines = text.split("\n");
        for (const line of lines) {
            if (line.startsWith("cpu ")) {
                const f = line.trim().split(/\s+/).slice(1).map(Number);
                const total = f.slice(0, 8).reduce((a, b) => a + b, 0);
                const idle = (f[3] || 0) + (f[4] || 0);
                if (lastTotal > 0 && total > lastTotal)
                    cpu = 1 - (idle - lastIdle) / (total - lastTotal);
                lastTotal = total;
                lastIdle = idle;
            } else if (line.startsWith("MemTotal:")) {
                memTotal = parseInt(line.split(/\s+/)[1]);
            } else if (line.startsWith("MemAvailable:")) {
                memUsed = memTotal - parseInt(line.split(/\s+/)[1]);
            } else if (/^\d+\.\d+ \d+\.\d+ \d+\.\d+ \d+\/\d+ \d+$/.test(line)) {
                load = line.split(" ").slice(0, 3).join(" ");
            } else if (/^\d+\.\d+ \d+\.\d+$/.test(line)) {
                const s = Math.floor(parseFloat(line));
                const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
                uptime = (d > 0 ? d + " d " : "") + (h > 0 ? h + " h " : "") + m + " min";
            }
        }
    }

    function parseTop(text) {
        const out = [];
        for (const line of text.split("\n")) {
            const m = line.trim().match(/^(.*\S)\s+([0-9.]+)$/);
            if (m) out.push({ name: m[1], cpu: parseFloat(m[2]) });
            if (out.length >= 5) break;
        }
        top = out;
    }

    Process {
        id: procFiles
        command: ["cat", "/proc/stat", "/proc/meminfo", "/proc/loadavg", "/proc/uptime"]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }

    Process {
        id: psProc
        command: ["ps", "-eo", "comm=,pcpu=", "--sort=-pcpu"]
        stdout: StdioCollector { onStreamFinished: root.parseTop(text) }
    }

    function sample() {
        if (!procFiles.running) procFiles.running = true;
        if (!psProc.running) psProc.running = true;
    }

    onActiveChanged: if (active) { lastTotal = 0; sample(); }

    Timer {
        interval: 2000
        running: root.active
        repeat: true
        onTriggered: root.sample()
    }
}
