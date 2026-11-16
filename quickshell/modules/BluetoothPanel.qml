// Bluetooth panel. Same look as WifiPanel.qml, but with Bluetooth's own content.
// Everything lives here, there is no separate settings program or popup:
// status, pairing questions (allow / confirm code / PIN), TOGGLES (Bluetooth,
// Discoverable, Pairable), and the PAIRED and NEARBY device lists with battery
// levels. Click a device to connect, disconnect or pair it; right-click a paired
// device to forget it. The panel opens by itself when a device asks to pair
// (services/BluetoothAgent.qml). UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    Overlay {
        id: win
        required property var modelData
        screen: modelData

        open: UIState.bluetooth
        layerNamespace: "qs-panel"
        onCloseRequested: {
            if (req !== null) BluetoothAgent.answer(false, "");   // Escape / outside click rejects
            else if (disp !== null) BluetoothAgent.dismissDisplay();
            else UIState.closeAll();
        }
        onShown: if (needsText) entry.forceActiveFocus()
        onReqChanged: { entry.text = ""; if (needsText && open) entry.forceActiveFocus(); }

        readonly property var req: BluetoothAgent.request
        readonly property var disp: BluetoothAgent.display
        readonly property bool needsText: req !== null && (req.kind === "pin" || req.kind === "passkey")

        function reqTitle() {
            if (req === null) return disp ? "Pair " + disp.name : "";
            switch (req.kind) {
            case "confirm":   return "Pair with " + req.name + "?";
            case "pin":       return "PIN for " + req.name;
            case "passkey":   return "Passkey for " + req.name;
            case "authorize": return req.name + " wants to pair";
            default:          return req.name + " wants to connect";
            }
        }

        function reqBody() {
            if (req === null) {
                if (!disp) return "";
                return disp.kind === "passkey"
                    ? "Type this passkey on " + disp.name + ", then press Enter there."
                    : "Enter this PIN on " + disp.name + ".";
            }
            switch (req.kind) {
            case "confirm":   return "Make sure this code is the same on both devices.";
            case "pin":       return "Enter the PIN shown on the device (often 0000 or 1234).";
            case "passkey":   return "Enter the 6-digit passkey shown on the device.";
            case "authorize": return "Allow this device to pair with this computer?";
            default:          return "Allow this device to use a service (" + (req.uuid || "unknown") + ")?";
            }
        }

        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property bool on: adapter !== null && adapter.enabled

        property string message: ""
        property string pendingAddress: ""   // device we asked to pair, waiting for the result
        property int pendingTicks: 0
        property int pairedCount: 0
        property int connectedCount: 0
        property int nearbyCount: 0
        property string lastSignature: ""

        onOpenChanged: {
            if (open) {
                message = "";
                pendingAddress = "";
                lastSignature = "";
                refreshRows();
                // Like the Wi-Fi panel, look for devices as soon as it opens.
                if (adapter !== null && adapter.enabled) adapter.discovering = true;
            } else if (adapter !== null && adapter.discovering) {
                // Discovery drains the battery; do not leave it running.
                adapter.discovering = false;
            }
        }

        function deviceFor(address) {
            for (const d of Array.from(Bluetooth.devices.values))
                if (d.address === address) return d;
            return null;
        }

        function order(a, b) {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if ((a.name === "") !== (b.name === "")) return a.name === "" ? 1 : -1;
            return (a.name || a.address).localeCompare(b.name || b.address);
        }

        // Rebuild the list only when its shape changed, so rows do not flicker.
        function refreshRows() {
            const all = Array.from(Bluetooth.devices.values);
            const paired = all.filter(d => d.paired).sort(order);
            const nearby = all.filter(d => !d.paired).sort(order);
            const next = paired.map(d => ({ address: d.address, group: "PAIRED", on: d.connected }))
                .concat(nearby.map(d => ({ address: d.address, group: "NEARBY", on: false })));
            pairedCount = paired.length;
            nearbyCount = nearby.length;
            connectedCount = paired.filter(d => d.connected).length;

            const signature = JSON.stringify(next);
            if (signature === lastSignature) return;
            lastSignature = signature;
            rows.clear();
            for (const r of next) rows.append({ address: r.address, group: r.group });
        }

        function activate(dev) {
            if (dev === null) return;
            message = "";
            if (dev.pairing) {
                dev.cancelPair();
                pendingAddress = "";
            } else if (dev.connected) {
                dev.disconnect();
            } else if (dev.paired) {
                dev.connect();
            } else {
                pendingAddress = dev.address;
                pendingTicks = 0;
                dev.pair();
            }
        }

        // After a pair request: once paired, trust it (so it reconnects by itself)
        // and connect; if pairing stopped without success, say so.
        function checkPending() {
            if (pendingAddress === "") return;
            const dev = deviceFor(pendingAddress);
            pendingTicks++;
            if (dev === null) { pendingAddress = ""; return; }
            if (dev.paired) {
                pendingAddress = "";
                dev.trusted = true;
                dev.connect();
            } else if (!dev.pairing && pendingTicks >= 3) {
                pendingAddress = "";
                message = "Pairing with " + (dev.name !== "" ? dev.name : dev.address) + " did not finish.";
            }
        }

        ListModel { id: rows }

        Connections {
            target: Bluetooth.devices
            function onValuesChanged() { win.refreshRows(); }
        }

        Timer {
            interval: 1000
            running: win.open
            repeat: true
            onTriggered: { win.refreshRows(); win.checkPending(); }
        }

        PanelFrame {
            progress: win.progress
            cardWidth: 440

            PanelHeader {
                title: win.adapter === null ? "Bluetooth" : (win.connectedCount > 0 ? "Connected" : "Bluetooth")
                BarButton {
                    visible: win.on
                    active: win.adapter !== null && win.adapter.discovering
                    onClicked: win.adapter.discovering = !win.adapter.discovering
                    Txt { text: (win.adapter !== null && win.adapter.discovering) ? "Scanning…" : "Scan"; color: Theme.subtext }
                }
            }

            Txt {
                width: parent.width
                text: win.adapter === null ? "NO ADAPTER"
                    : !win.on ? "OFF"
                    : win.connectedCount > 0 ? "CONNECTED (" + win.connectedCount + ")" : "NOT CONNECTED"
                color: win.on && win.connectedCount > 0 ? Theme.green : Theme.subtext
                font.pixelSize: Config.fontSize - 2
            }

            // A device is asking something (allow, confirm a code, type a PIN).
            Rectangle {
                width: parent.width
                height: ask.implicitHeight + 24
                visible: win.req !== null || win.disp !== null
                color: Theme.surface
                border.color: Theme.accent
                border.width: 1

                Column {
                    id: ask
                    x: 12
                    y: 12
                    width: parent.width - 24
                    spacing: 8

                    Txt { width: parent.width; text: win.reqTitle(); font.bold: true; wrapMode: Text.WordWrap }
                    Txt {
                        width: parent.width
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                        text: win.req !== null ? (win.req.code || "") : (win.disp ? win.disp.code : "")
                        color: Theme.accent
                        font.pixelSize: 28
                        font.bold: true
                        font.letterSpacing: 4
                    }
                    Txt { width: parent.width; text: win.reqBody(); wrapMode: Text.WordWrap; color: Theme.subtext; font.pixelSize: Config.fontSize - 2 }

                    Rectangle {
                        width: parent.width
                        height: 30
                        visible: win.needsText
                        color: Theme.bg
                        border.color: Theme.accent
                        border.width: 1
                        TextInput {
                            id: entry
                            anchors.fill: parent
                            anchors.margins: 6
                            color: Theme.text
                            font.family: Config.fontFamily
                            font.pixelSize: Config.fontSize
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            maximumLength: win.req !== null && win.req.kind === "passkey" ? 6 : 16
                            inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                            validator: RegularExpressionValidator {
                                regularExpression: win.req !== null && win.req.kind === "passkey" ? /[0-9]{0,6}/ : /[^ ]{0,16}/
                            }
                            onAccepted: if (text !== "") BluetoothAgent.answer(true, text)
                        }
                    }

                    Row {
                        spacing: 8
                        layoutDirection: Qt.RightToLeft
                        width: parent.width
                        BarButton {
                            visible: win.req !== null
                            onClicked: {
                                if (win.needsText) { if (entry.text !== "") BluetoothAgent.answer(true, entry.text); }
                                else BluetoothAgent.answer(true, "");
                            }
                            Txt {
                                text: win.req === null ? "" : win.needsText ? "Pair" : (win.req.kind === "confirm" ? "Yes, match" : "Allow")
                                color: Theme.accent
                            }
                        }
                        BarButton {
                            onClicked: win.closeRequested()
                            Txt { text: win.req !== null ? "Reject" : "Close"; color: Theme.subtext }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; visible: win.adapter !== null }

            // Settings that switch something on or off.
            Column {
                width: parent.width
                spacing: 8
                visible: win.adapter !== null

                Txt { text: "TOGGLES"; color: Theme.subtext; font.pixelSize: Config.fontSize - 2 }
                ToggleRow { label: "Bluetooth"; checked: win.on; onToggled: win.adapter.enabled = !win.adapter.enabled }
                ToggleRow { label: "Discoverable"; visible: win.on; checked: win.adapter !== null && win.adapter.discoverable; onToggled: win.adapter.discoverable = !win.adapter.discoverable }
                ToggleRow { label: "Pairable"; visible: win.on; checked: win.adapter !== null && win.adapter.pairable; onToggled: win.adapter.pairable = !win.adapter.pairable }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; visible: win.adapter !== null }

            Txt {
                width: parent.width
                visible: win.adapter === null
                wrapMode: Text.WordWrap
                text: "No Bluetooth adapter found. (A virtual machine usually has none; check that bluetooth.service is running.)"
                color: Theme.subtext
            }

            Txt {
                width: parent.width
                visible: win.adapter !== null && !win.on
                text: "Bluetooth is off."
                color: Theme.subtext
            }

            ListView {
                id: list
                width: parent.width
                height: Math.min(contentHeight, 240)
                visible: win.on
                clip: true
                spacing: 2
                model: rows

                section.property: "group"
                section.criteria: ViewSection.FullString
                section.delegate: Txt {
                    required property string section
                    width: list.width
                    height: 28
                    text: section
                    color: Theme.subtext
                    font.pixelSize: Config.fontSize - 2
                    verticalAlignment: Text.AlignBottom
                }

                delegate: ListRow {
                    id: row
                    required property string address
                    readonly property var dev: win.deviceFor(address)

                    glyph: dev !== null && dev.connected ? Icons.bluetoothConnected : Icons.bluetooth
                    glyphColor: dev !== null && dev.connected ? Theme.green : Theme.text
                    title: dev === null ? address : (dev.name !== "" ? dev.name : dev.address)
                    subtitle: dev === null ? ""
                        : dev.pairing ? "Pairing…"
                        : dev.connected ? "Connected"
                        : dev.paired ? "Paired" : "Available"
                    trailing: dev !== null && dev.batteryAvailable ? Math.round(dev.battery * 100) + "%" : ""
                    highlighted: dev !== null && dev.connected
                    onClicked: win.activate(dev)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: if (row.dev !== null && row.dev.paired) row.dev.forget()
                    }
                }
            }

            Txt {
                width: parent.width
                visible: win.on && rows.count === 0 && !(win.adapter !== null && win.adapter.discovering)
                text: "No devices found."
                color: Theme.subtext
            }

            Txt {
                width: parent.width
                visible: win.pendingAddress !== ""
                text: "Pairing…"
                color: Theme.yellow
            }
            Txt {
                width: parent.width
                visible: win.message !== ""
                wrapMode: Text.WordWrap
                text: win.message
                color: Theme.red
            }
            Txt {
                width: parent.width
                visible: !BluetoothAgent.ready
                wrapMode: Text.WordWrap
                text: "Pairing agent not running" + (BluetoothAgent.error !== "" ? ": " + BluetoothAgent.error : ".")
                color: Theme.red
                font.pixelSize: Config.fontSize - 2
            }
            Txt {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Right-click a paired device to forget it."
                color: Theme.subtext
                font.pixelSize: Config.fontSize - 2
            }
        }
    }
}
