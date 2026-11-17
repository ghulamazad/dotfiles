// Bluetooth panel. Same look as the other bar panels, with Omarchy's Bluetooth
// panel behaviour:
//  * a hero line (icon, status, scan button, on/off switch);
//  * CONNECTED devices on top, then a scrollable PAIRED / AVAILABLE list
//    (AVAILABLE appears while scanning); battery level shown on connected devices;
//  * keyboard: j/k or arrows move, Enter connects or disconnects, l/right focuses the
//    forget button, x or Delete forgets, b switches Bluetooth, s pauses scanning,
//    Esc closes. The mouse works too (hover selects, right-click forgets or disconnects);
//  * actions run through bin/bt-device.sh, power through bin/bt-power.sh (rfkill, so
//    the state survives a reboot); scanning is managed by services/BluetoothScan.qml;
//  * after a device connects, its audio output becomes the default.
// Unlike Omarchy's panel it also answers pairing questions (allow, confirm code,
// PIN) inside the panel, and has Discoverable / Pairable switches. Left out:
// the rotating status phrases (translation strings, an extra timer and animation).
// UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
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
        onShown: focusInput()
        onReqChanged: { entry.text = ""; if (open) focusInput(); }
        onDispChanged: if (open) focusInput()

        // The pairing prompt's text field owns the keyboard while it is showing;
        // otherwise the key catcher below does.
        function focusInput() {
            if (needsText) entry.forceActiveFocus();
            else keys.forceActiveFocus();
        }

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
        readonly property bool scanning: BluetoothScan.scanning

        property string message: ""
        property var pending: ({})           // address -> { action, since }
        property string audioAddress: ""     // connected device whose audio output we should switch to
        property int audioTries: 0
        property int connectedCount: 0
        property var order: []               // every shown address, top to bottom (keyboard order)
        property string lastSignature: ""

        // Keyboard / hover cursor. `cursorOnHeader` is the power switch.
        property bool cursorActive: false
        property bool cursorOnHeader: false
        property string cursorAddress: ""
        property bool actionFocused: false   // the forget button of the selected row

        onOpenChanged: {
            BluetoothScan.active = open;
            if (open) {
                message = "";
                lastSignature = "";
                cursorActive = false;
                actionFocused = false;
                refreshRows();
                cursorOnHeader = order.length === 0;
                cursorAddress = order.length > 0 ? order[0] : "";
            }
        }

        function deviceFor(address) {
            for (const d of Array.from(Bluetooth.devices.values))
                if (d.address === address) return d;
            return null;
        }

        function label(d) { return d.name !== "" ? d.name : d.address; }

        // Devices that only advertise an address or a UUID are noise; hide them.
        function hasHumanName(d) {
            const n = String(d.name || "").trim();
            if (n === "") return false;
            if (/^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(n)) return false;
            if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(n)) return false;
            if (/^[0-9a-f]{32}$/i.test(n) || /^0x[0-9a-f]{4,32}$/i.test(n)) return false;
            return true;
        }

        function isKnown(d) { return d.paired || d.trusted || d.bonded === true; }

        function byName(a, b) { return a.name.localeCompare(b.name); }

        // Rebuild the lists only when their content changed, so rows do not flicker.
        // Models hold plain strings only: a live device object stored in a model can
        // be destroyed by BlueZ while a row is still being created.
        function refreshRows() {
            const all = Array.from(Bluetooth.devices.values).filter(hasHumanName);
            const connected = all.filter(d => d.connected).sort(byName);
            const known = all.filter(d => !d.connected && isKnown(d)).sort(byName);
            const available = scanning ? all.filter(d => !d.connected && !isKnown(d)).sort(byName) : [];
            connectedCount = connected.length;

            const nextConnected = connected.map(d => d.address);
            const nextScroll = known.map(d => ({ address: d.address, group: "PAIRED" }))
                .concat(available.map(d => ({ address: d.address, group: "AVAILABLE" })));

            const signature = JSON.stringify([nextConnected, nextScroll]);
            if (signature === lastSignature) return;
            lastSignature = signature;

            const oldIndex = order.indexOf(cursorAddress);
            connectedModel.clear();
            for (const a of nextConnected) connectedModel.append({ address: a });
            scrollModel.clear();
            for (const r of nextScroll) scrollModel.append(r);
            order = nextConnected.concat(nextScroll.map(r => r.address));

            // Keep the cursor on the same device when rows move between sections;
            // if that device is gone, land on its neighbour.
            if (!cursorOnHeader && order.indexOf(cursorAddress) < 0) {
                if (order.length === 0) { cursorOnHeader = true; cursorAddress = ""; }
                else cursorAddress = order[Math.max(0, Math.min(oldIndex, order.length - 1))];
                actionFocused = false;
            }
        }

        // ---- cursor and keyboard ----
        function move(delta) {
            if (!cursorActive) { cursorActive = true; return; }
            const i = cursorOnHeader ? -1 : order.indexOf(cursorAddress);
            const n = Math.max(-1, Math.min(order.length - 1, i + delta));
            actionFocused = false;
            if (n < 0) { cursorOnHeader = true; cursorAddress = ""; }
            else { cursorOnHeader = false; cursorAddress = order[n]; }
        }

        function selectRow(address, forgetButton) {
            cursorActive = true;
            cursorOnHeader = false;
            cursorAddress = address;
            actionFocused = forgetButton;
        }

        function canForget(address) {
            const d = deviceFor(address);
            return d !== null && (d.connected || isKnown(d));
        }

        function activateCursor() {
            if (!cursorActive) { cursorActive = true; return; }
            if (cursorOnHeader) { setPower(!on); return; }
            const d = deviceFor(cursorAddress);
            if (d === null) return;
            if (actionFocused) forget(d);
            else activate(d);
        }

        function handleKey(event) {
            if (req !== null || disp !== null) return;      // the prompt owns the keyboard
            const k = event.key;
            let used = true;
            if (k === Qt.Key_J || k === Qt.Key_Down) move(1);
            else if (k === Qt.Key_K || k === Qt.Key_Up) move(-1);
            else if (k === Qt.Key_L || k === Qt.Key_Right) { if (cursorActive && !cursorOnHeader && canForget(cursorAddress)) actionFocused = true; }
            else if (k === Qt.Key_H || k === Qt.Key_Left) actionFocused = false;
            else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) activateCursor();
            else if (k === Qt.Key_X || k === Qt.Key_Delete) { if (cursorActive && !cursorOnHeader) forget(deviceFor(cursorAddress)); }
            else if (k === Qt.Key_B) setPower(!on);
            else if (k === Qt.Key_S) BluetoothScan.toggle();
            else used = false;
            event.accepted = used;
        }

        // Scroll the list so the selected row is visible (deferred a turn: the
        // model may have just been rebuilt).
        function ensureVisible() {
            for (let i = 0; i < scrollModel.count; i++) {
                if (scrollModel.get(i).address === cursorAddress) {
                    list.positionViewAtIndex(i, ListView.Contain);
                    return;
                }
            }
        }
        onCursorAddressChanged: Qt.callLater(ensureVisible)

        // ---- actions (run through the helper scripts) ----
        function pendingAction(address) {
            return pending[address] !== undefined ? pending[address].action : "";
        }

        function setPending(address, action) {
            const next = Object.assign({}, pending);
            if (action === "") delete next[address];
            else next[address] = { action: action, since: Date.now() };
            pending = next;
        }

        function runDevice(action, dev, pendingLabel) {
            setPending(dev.address, pendingLabel);
            Quickshell.execDetached([Config.scriptsDir + "/bt-device.sh", action, dev.address]);
        }

        function activate(dev) {
            if (dev === null || pendingAction(dev.address) !== "") return;
            message = "";
            if (dev.connected) {
                dev.disconnect();
                runDevice("disconnect", dev, "disconnecting");
            } else if (isKnown(dev)) {
                runDevice("connect", dev, "connecting");
            } else {
                runDevice("pair", dev, "pairing");
            }
        }

        function forget(dev) {
            if (dev !== null && (dev.connected || isKnown(dev)) && pendingAction(dev.address) === "")
                runDevice("forget", dev, "forgetting");
        }

        // A direction, not a toggle: the helper runs detached and the switch moves
        // only once BlueZ catches up, so a second press in that window must not
        // re-read the old state and undo the first.
        function setPower(wantOn) {
            Quickshell.execDetached([Config.scriptsDir + "/bt-power.sh", wantOn ? "on" : "off"]);
        }

        // Called every second while open: clear finished or stuck actions.
        function syncPending() {
            const now = Date.now();
            const next = Object.assign({}, pending);
            let changed = false;
            for (const address in next) {
                const p = next[address];
                const dev = deviceFor(address);
                const joining = p.action === "connecting" || p.action === "pairing";
                const done = joining ? (dev !== null && dev.connected)
                    : p.action === "disconnecting" ? (dev === null || !dev.connected)
                    : (dev === null || !(dev.connected || isKnown(dev)));   // forgetting
                const limit = p.action === "pairing" ? 75000 : 25000;
                if (done || now - p.since > limit) {
                    if (done && joining) {
                        audioAddress = address;
                        audioTries = 0;
                    } else if (!done && joining && dev !== null) {
                        message = "Could not connect to " + label(dev) + ".";
                    }
                    delete next[address];
                    changed = true;
                }
            }
            if (changed) pending = next;
        }

        // After a connect, make the device's audio output the default (earbuds,
        // speakers). Its sink appears a moment later, so retry for a few seconds.
        function norm(s) { return String(s || "").toLowerCase().replace(/[^0-9a-f]/g, ""); }

        function switchAudio() {
            if (audioAddress === "") return;
            const want = norm(audioAddress);
            for (const node of Array.from(Pipewire.nodes.values)) {
                if (node && node.isSink && !node.isStream && norm(node.name).indexOf(want) !== -1) {
                    Pipewire.preferredDefaultAudioSink = node;
                    Quickshell.execDetached(["wpctl", "set-default", String(node.id)]);
                    audioAddress = "";
                    return;
                }
            }
            audioTries++;
            if (audioTries >= 8) audioAddress = "";
        }

        ListModel { id: connectedModel }
        ListModel { id: scrollModel }

        // Only work while the panel is showing.
        Connections {
            target: Bluetooth.devices
            function onValuesChanged() { if (win.open) win.refreshRows(); }
        }

        Timer {
            interval: 1000
            running: win.open
            repeat: true
            onTriggered: { win.refreshRows(); win.syncPending(); win.switchAudio(); }
        }

        // Receives the keyboard while the panel is open (see focusInput()).
        Item {
            id: keys
            focus: true
            Keys.onPressed: event => win.handleKey(event)
        }

        // One device line: icon, name, status or battery, and a forget button.
        component DeviceRow: Rectangle {
            id: row
            required property string address
            readonly property var dev: win.deviceFor(address)
            readonly property bool connected: dev !== null && dev.connected
            readonly property int devState: dev !== null && dev.state !== undefined ? dev.state : -1
            readonly property string action: win.pendingAction(address)
            readonly property bool canForget: dev !== null && (dev.connected || win.isKnown(dev))
            readonly property bool selected: win.cursorActive && !win.cursorOnHeader && win.cursorAddress === address
            readonly property bool showForget: canForget && action === "" && (selected || hover.containsMouse)

            readonly property string statusText: {
                if (dev === null) return "";
                if (action === "forgetting") return "Removing…";
                if (action === "disconnecting" || devState === 2) return "Disconnecting…";
                if (connected) return dev.batteryAvailable ? Math.round(dev.battery * 100) + "%" : "";
                if (action === "pairing") return "Pairing…";
                if (action === "connecting" || devState === 3 || dev.pairing === true) return "Connecting…";
                return "";
            }

            height: Config.px(44)
            color: (selected && !win.actionFocused) ? Theme.select : (connected ? Theme.surface : "transparent")

            Rectangle {
                visible: row.connected
                width: 2
                height: parent.height
                color: Theme.green
            }

            Txt {
                id: glyph
                x: Config.px(10)
                width: Config.px(24)
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: row.connected ? Icons.bluetoothConnected : Icons.bluetooth
                color: row.connected ? Theme.green : Theme.text
                font.pixelSize: Config.px(16)
            }

            Column {
                anchors.left: glyph.right
                anchors.leftMargin: 10
                anchors.right: forgetBtn.visible ? forgetBtn.left : parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                Txt { width: parent.width; text: row.dev === null ? row.address : win.label(row.dev); elide: Text.ElideRight }
                Txt {
                    width: parent.width
                    visible: row.statusText !== ""
                    text: row.statusText
                    color: Theme.subtext
                    font.pixelSize: Config.fontSmall
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onContainsMouseChanged: if (containsMouse) win.selectRow(row.address, false)
                onClicked: event => {
                    if (row.dev === null) return;
                    if (event.button === Qt.RightButton) {
                        if (row.connected) win.activate(row.dev);     // disconnect
                        else win.forget(row.dev);
                    } else {
                        win.activate(row.dev);
                    }
                }
            }

            Rectangle {
                id: forgetBtn
                visible: row.showForget
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: Config.px(24)
                height: Config.px(24)
                radius: Config.radius
                color: (forgetMouse.containsMouse || (row.selected && win.actionFocused)) ? Theme.select : "transparent"
                border.color: (row.selected && win.actionFocused) ? Theme.accent : "transparent"
                border.width: 1
                Txt { anchors.centerIn: parent; text: Icons.close; color: Theme.red }
                MouseArea {
                    id: forgetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: if (containsMouse) win.selectRow(row.address, true)
                    onClicked: win.forget(row.dev)
                }
            }
        }

        PanelFrame {
            progress: win.progress
            cardWidth: Config.px(440)

            // Hero: icon, title and status, scan button and the on/off switch.
            Item {
                width: parent.width
                height: Config.px(44)
                visible: win.adapter !== null

                Txt {
                    id: heroIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: !win.on ? Icons.bluetoothOff : (win.connectedCount > 0 ? Icons.bluetoothConnected : Icons.bluetooth)
                    color: win.connectedCount > 0 ? Theme.green : (win.on ? Theme.text : Theme.muted)
                    font.pixelSize: Config.px(26)
                }

                Column {
                    anchors.left: heroIcon.right
                    anchors.leftMargin: 12
                    anchors.right: heroControls.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Txt { width: parent.width; text: "Bluetooth"; font.bold: true; font.pixelSize: Config.px(16) }
                    Txt {
                        width: parent.width
                        text: !win.on ? "TURNED OFF"
                            : win.connectedCount > 0 ? "CONNECTED (" + win.connectedCount + ")"
                            : win.scanning ? "SCANNING FOR DEVICES" : "NOT CONNECTED"
                        color: win.connectedCount > 0 ? Theme.green : Theme.subtext
                        font.pixelSize: Config.fontSmall
                    }
                }

                Row {
                    id: heroControls
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Config.px(8)

                    BarButton {
                        visible: win.on
                        active: win.scanning
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: BluetoothScan.toggle()
                        Txt { text: win.scanning ? "Scanning…" : "Scan"; color: Theme.subtext }
                    }

                    Rectangle {
                        width: powerSwitch.width + 8
                        height: powerSwitch.height + 8
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        border.color: win.cursorActive && win.cursorOnHeader ? Theme.accent : "transparent"
                        border.width: 1
                        Toggle {
                            id: powerSwitch
                            anchors.centerIn: parent
                            checked: win.on
                            onToggled: win.setPower(!win.on)
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            onContainsMouseChanged: if (containsMouse) { win.cursorActive = true; win.cursorOnHeader = true; win.actionFocused = false; }
                        }
                    }
                }
            }

            // A device is asking something (allow, confirm a code, type a PIN).
            Rectangle {
                width: parent.width
                height: ask.implicitHeight + Config.px(24)
                visible: win.req !== null || win.disp !== null
                color: Theme.surface
                border.color: Theme.accent
                border.width: 1

                Column {
                    id: ask
                    x: Config.px(12)
                    y: Config.px(12)
                    width: parent.width - Config.px(24)
                    spacing: Config.px(8)

                    Txt { width: parent.width; text: win.reqTitle(); font.bold: true; wrapMode: Text.WordWrap }
                    Txt {
                        width: parent.width
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                        text: win.req !== null ? (win.req.code || "") : (win.disp ? win.disp.code : "")
                        color: Theme.accent
                        font.pixelSize: Config.px(28)
                        font.bold: true
                        font.letterSpacing: 4
                    }
                    Txt { width: parent.width; text: win.reqBody(); wrapMode: Text.WordWrap; color: Theme.subtext; font.pixelSize: Config.fontSmall }

                    Rectangle {
                        width: parent.width
                        height: Config.px(30)
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
                        spacing: Config.px(8)
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

            Divider { visible: win.adapter !== null }

            // Settings that switch something on or off.
            Column {
                width: parent.width
                spacing: Config.px(8)
                visible: win.on

                SectionLabel { text: "TOGGLES" }
                ToggleRow { label: "Discoverable"; checked: win.adapter !== null && win.adapter.discoverable; onToggled: win.adapter.discoverable = !win.adapter.discoverable }
                ToggleRow { label: "Pairable"; checked: win.adapter !== null && win.adapter.pairable; onToggled: win.adapter.pairable = !win.adapter.pairable }
            }

            Divider { visible: win.on }

            Txt {
                width: parent.width
                visible: win.adapter === null
                wrapMode: Text.WordWrap
                text: "No Bluetooth adapter found. (A virtual machine usually has none; check that bluetooth.service is running.)"
                color: Theme.subtext
            }

            // Connected devices, always visible above the scrolling list.
            Column {
                width: parent.width
                visible: win.on && connectedModel.count > 0
                spacing: Config.px(2)

                SectionLabel { text: "CONNECTED"; height: Config.px(24); verticalAlignment: Text.AlignBottom }
                Repeater {
                    model: connectedModel
                    delegate: DeviceRow {
                        width: parent.width
                    }
                }
            }

            // Paired devices, then (while scanning) nearby ones.
            ListView {
                id: list
                width: parent.width
                height: Math.min(contentHeight, Config.px(280))
                visible: win.on && scrollModel.count > 0
                clip: true
                spacing: Config.px(2)
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height
                model: scrollModel

                section.property: "group"
                section.criteria: ViewSection.FullString
                section.delegate: Txt {
                    required property string section
                    width: list.width
                    height: Config.px(28)
                    text: section
                    color: Theme.subtext
                    font.pixelSize: Config.fontSmall
                    verticalAlignment: Text.AlignBottom
                }

                delegate: DeviceRow {
                    width: list.width
                }
            }

            Txt {
                width: parent.width
                visible: win.on && connectedModel.count === 0 && scrollModel.count === 0
                text: win.scanning ? "Scanning for devices…" : "No devices found. Press Scan."
                color: Theme.subtext
            }
            Txt {
                width: parent.width
                visible: win.adapter !== null && !win.on
                text: "Bluetooth is off. Turn it on to scan."
                color: Theme.subtext
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
                font.pixelSize: Config.fontSmall
            }
            Txt {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "j/k move   Enter connect   l then Enter or x forget   b power   s scan   Esc close"
                color: Theme.subtext
                font.pixelSize: Config.fontSmall
            }
        }
    }
}
