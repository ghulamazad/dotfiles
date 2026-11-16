pragma Singleton
// Bluetooth pairing agent: answers BlueZ's "confirm this passkey", "enter the
// PIN" and "allow this connection" questions inside the Bluetooth
// panel (modules/BluetoothPanel.qml). The D-Bus side lives in scripts/bt-agent.py;
// this file only speaks its JSON-lines protocol over stdin/stdout.
//
// `request`  is set while BlueZ waits for your answer (fields: id, kind, name, address, code, uuid).
//            kind is confirm | pin | passkey | authorize | service
// `display`  is set while BlueZ wants YOU to type a code on the other device.
// Needs python-dbus and python-gobject (packages.txt). If they are missing the
// pairing questions never appear and `error` says why; pairing then needs bluetoothctl.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property var request: null
    property var display: null
    property bool ready: false
    property string error: ""

    function answer(accept, value) {
        if (request === null) return;
        // The PIN goes over the pipe to the helper, never onto a command line.
        helper.write(JSON.stringify({ id: request.id, accept: accept, value: value || "" }) + "\n");
        request = null;
    }

    // The question is answered inside the Bluetooth panel, so open it.
    function showPanel() { if (!UIState.bluetooth) UIState.toggleBluetooth(); }

    function dismissDisplay() { display = null; }

    function handle(line) {
        let msg;
        try { msg = JSON.parse(line); } catch (e) { return; }
        if (msg.event === "ready") { ready = true; error = ""; }
        else if (msg.event === "request") { display = null; request = msg; showPanel(); }
        else if (msg.event === "display") { display = msg; showPanel(); }
        else if (msg.event === "cancel") { request = null; display = null; }
        else if (msg.event === "error") error = msg.message || "Bluetooth agent error";
    }

    Process {
        id: helper
        running: true
        command: ["python3", Config.scriptsDir + "/bt-agent.py"]
        stdinEnabled: true
        stdout: SplitParser { onRead: line => root.handle(line) }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim() !== "") root.error = text.trim()
        }
        onExited: code => {
            root.ready = false;
            root.request = null;
            root.display = null;
            // 3 = python modules missing, 4 = BlueZ not running: retrying will not help.
            // Anything else (a crash, bluetoothd restarting): try again shortly.
            if (code !== 3 && code !== 4) retry.start();
        }
    }

    Timer { id: retry; interval: 5000; onTriggered: helper.running = true }
}
