pragma Singleton
// CPU, RAM, network throughput and CPU temperature, from /proc and /sys.
// Reads are small and happen every 2 seconds; temperature is only sampled
// while a consumer (the dashboard) sets sampleTemp = true.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property real cpu: 0            // 0.0 to 1.0
    property real ramFraction: 0    // 0.0 to 1.0
    property real ramUsedGiB: 0
    property real ramTotalGiB: 0
    property real rxRate: 0         // bytes per second
    property real txRate: 0
    property real cpuTemp: -1       // degrees C, -1 = unsupported or unknown
    property bool sampleTemp: false

    property var _prevCpu: null
    property var _prevNet: null

    function parseStat(txt) {
        const p = txt.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        if (p.length < 5) return;
        const idle = p[3] + (p[4] || 0);
        const total = p.slice(0, 8).reduce((a, b) => a + (b || 0), 0);
        if (_prevCpu) {
            const dt = total - _prevCpu.total;
            const di = idle - _prevCpu.idle;
            if (dt > 0) cpu = Math.max(0, Math.min(1, 1 - di / dt));
        }
        _prevCpu = { idle: idle, total: total };
    }

    function parseMem(txt) {
        const t = /MemTotal:\s+(\d+)/.exec(txt);
        const a = /MemAvailable:\s+(\d+)/.exec(txt);
        if (!t || !a) return;
        const total = Number(t[1]);
        const used = total - Number(a[1]);
        ramTotalGiB = total / 1048576;
        ramUsedGiB = used / 1048576;
        ramFraction = total > 0 ? used / total : 0;
    }

    function parseNet(txt) {
        let rx = 0, tx = 0;
        for (const line of txt.split("\n").slice(2)) {
            const idx = line.indexOf(":");
            if (idx < 0) continue;
            if (line.slice(0, idx).trim() === "lo") continue;
            const f = line.slice(idx + 1).trim().split(/\s+/).map(Number);
            rx += f[0] || 0;
            tx += f[8] || 0;
        }
        const now = Date.now();
        if (_prevNet) {
            const dt = (now - _prevNet.t) / 1000;
            if (dt > 0) {
                rxRate = Math.max(0, (rx - _prevNet.rx) / dt);
                txRate = Math.max(0, (tx - _prevNet.tx) / dt);
            }
        }
        _prevNet = { rx: rx, tx: tx, t: now };
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec >= 1048576) return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
        if (bytesPerSec >= 1024) return Math.round(bytesPerSec / 1024) + " KB/s";
        return Math.round(bytesPerSec) + " B/s";
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            mem.reload();
            net.reload();
        }
    }

    Timer {
        interval: 5000
        running: root.sampleTemp
        repeat: true
        triggeredOnStart: true
        onTriggered: tempProc.running = true
    }

    FileView { id: stat; path: "/proc/stat"; printErrors: false; onLoaded: root.parseStat(text()) }
    FileView { id: mem; path: "/proc/meminfo"; printErrors: false; onLoaded: root.parseMem(text()) }
    FileView { id: net; path: "/proc/net/dev"; printErrors: false; onLoaded: root.parseNet(text()) }

    Process {
        id: tempProc
        command: [Config.scriptsDir + "/cpu-temp.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text);
                root.cpuTemp = isNaN(v) ? -1 : v;
            }
        }
    }
}
