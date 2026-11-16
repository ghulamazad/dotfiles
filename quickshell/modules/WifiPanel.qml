// Network panel: connection stats, DNS provider, speed test, on/off,
// and the list of known / other networks. New secured networks ask for a
// password here; it goes to NetworkManager through a private file, never a
// command line (see services/Network.qml). UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
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

        open: UIState.wifi
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        property var asking: null     // network waiting for a password
        property bool dnsCustomOpen: false   // custom DNS input visible

        onOpenChanged: {
            Network.statsActive = open;
            if (open) {
                asking = null;
                password.text = "";
                win.dnsCustomOpen = false;
                dnsCustomInput.text = "";
                Network.refresh();
                Network.scan();
            }
        }

        // Small text button used for the DNS choices.
        component Choice: Rectangle {
            id: choice
            property string label: ""
            property bool active: false
            signal clicked()
            width: (parent.width - 3 * parent.spacing) / 4
            height: 34
            radius: Config.radius
            color: (active || m.containsMouse) ? Theme.surface2 : "transparent"
            border.color: Theme.border
            border.width: 1
            Txt { anchors.centerIn: parent; text: choice.label; color: choice.active ? Theme.accent : Theme.text }
            MouseArea {
                id: m
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: choice.clicked()
            }
        }

        // One "label ........ value" cell of the stats grid.
        component Stat: Item {
            id: stat
            property string label: ""
            property string value: ""
            width: (parent.width - parent.columnSpacing) / 2
            height: 20
            Txt { anchors.left: parent.left; text: stat.label; color: Theme.subtext }
            Txt {
                anchors.right: parent.right
                width: Math.min(implicitWidth, parent.width - 90)
                text: stat.value
                horizontalAlignment: Text.AlignRight
            }
        }

        PanelFrame {
            progress: win.progress
            cardWidth: 440

            PanelHeader {
                title: Network.connected ? Network.name : "Wi-Fi"
                BarButton {
                    visible: Network.connected
                    active: Network.speedRunning
                    onClicked: Network.runSpeedTest()
                    Txt { text: Network.speedRunning ? "Testing…" : "Speed" }
                }
                BarButton {
                    visible: Network.wifiAvailable
                    onClicked: Network.scan()
                    Txt { text: Network.scanning ? "Scanning…" : "Rescan"; color: Theme.subtext }
                }
                BarButton {
                    visible: Network.wifiAvailable
                    active: Network.wifiEnabled
                    onClicked: Network.setWifi(!Network.wifiEnabled)
                    Txt { text: Network.wifiEnabled ? "On" : "Off" }
                }
            }

            Txt {
                width: parent.width
                text: Network.connected ? (Network.kind === "wifi" ? "CONNECTED (WI-FI)" : "CONNECTED (ETHERNET)") : "NOT CONNECTED"
                color: Network.connected ? Theme.green : Theme.subtext
                font.pixelSize: Config.fontSize - 2
            }

            // Stats
            Grid {
                id: stats
                width: parent.width
                columns: 2
                columnSpacing: 24
                rowSpacing: 4
                visible: Network.connected

                Stat { label: "Ping"; value: Network.pingMs < 0 ? "-" : Math.round(Network.pingMs) + " ms" }
                Stat { label: "Packet Loss"; value: Network.lossPct < 0 ? "-" : Network.lossPct + "%" }
                Stat { label: "Receiving"; value: Network.fmtRate(Network.rxRate) }
                Stat { label: "Sending"; value: Network.fmtRate(Network.txRate) }
                Stat { label: "Downloaded"; value: Network.fmtBytes(Network.rxTotal) }
                Stat { label: "Uploaded"; value: Network.fmtBytes(Network.txTotal) }
                Stat { label: "IP Address"; value: Network.ipAddress }
                Stat { label: "Gateway"; value: Network.gateway }
            }

            Txt {
                width: parent.width
                visible: Network.speedRunning || Network.speedMbps >= 0 || Network.speedMessage !== ""
                text: Network.speedRunning ? "Speed test: downloading 25 MB from Cloudflare…"
                    : Network.speedMbps >= 0 ? "Download speed: " + Network.speedMbps.toFixed(1) + " Mbps"
                    : Network.speedMessage
                color: Network.speedMbps >= 0 || Network.speedRunning ? Theme.accent : Theme.red
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; visible: Network.connected }

            // DNS provider
            Column {
                width: parent.width
                spacing: 8
                visible: Network.connected

                Txt { text: "DNS PROVIDER"; color: Theme.subtext; font.pixelSize: Config.fontSize - 2 }
                Row {
                    id: dnsRow
                    width: parent.width
                    spacing: 6
                    opacity: Network.dnsBusy ? 0.5 : 1
                    Choice { label: "DHCP"; active: Network.dnsMode === "dhcp"; onClicked: Network.setDns("dhcp", "") }
                    Choice { label: "Cloudflare"; active: Network.dnsMode === "cloudflare"; onClicked: Network.setDns("cloudflare", "") }
                    Choice { label: "Google"; active: Network.dnsMode === "google"; onClicked: Network.setDns("google", "") }
                    Choice {
                        label: "Custom"
                        active: Network.dnsMode === "custom" || win.dnsCustomOpen
                        onClicked: {
                            win.dnsCustomOpen = !win.dnsCustomOpen;
                            if (win.dnsCustomOpen) {
                                dnsCustomInput.text = Network.dnsCustom;
                                dnsCustomInput.forceActiveFocus();
                            }
                        }
                    }
                }
                Column {
                    width: parent.width
                    spacing: 4
                    visible: win.dnsCustomOpen
                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: Config.radius
                        color: Theme.surface
                        border.color: Theme.accent
                        border.width: 1
                        TextInput {
                            id: dnsCustomInput
                            anchors.fill: parent
                            anchors.margins: 8
                            color: Theme.text
                            font.family: Config.fontFamily
                            font.pixelSize: Config.fontSize
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            onAccepted: Network.setDns("custom", text)
                        }
                    }
                    Txt {
                        text: "Up to 4 IPv4/IPv6 addresses, separated by spaces. Enter to apply."
                        color: Theme.subtext
                        font.pixelSize: Config.fontSize - 2
                    }
                }
                Txt {
                    width: parent.width
                    visible: Network.dnsMessage !== ""
                    wrapMode: Text.WordWrap
                    text: Network.dnsMessage
                    color: Theme.red
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; visible: Network.connected }

            Txt {
                width: parent.width
                visible: !Network.wifiAvailable
                wrapMode: Text.WordWrap
                text: "No Wi-Fi adapter found. (A virtual machine usually has none; its network is wired.)"
                color: Theme.subtext
            }

            Txt {
                width: parent.width
                visible: Network.wifiAvailable && !Network.wifiEnabled
                text: "Wi-Fi is off."
                color: Theme.subtext
            }

            ListView {
                id: list
                width: parent.width
                height: Math.min(contentHeight, 240)
                visible: Network.wifiEnabled
                clip: true
                spacing: 2
                model: Network.networks

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
                    required property var modelData
                    glyph: Icons.wifi
                    glyphColor: modelData.inUse ? Theme.green : Theme.text
                    title: modelData.ssid
                    subtitle: modelData.inUse ? "Connected"
                        : modelData.known ? "Saved"
                        : modelData.secure ? "Secured" : "Open"
                    trailing: (modelData.secure ? Icons.lockClosed + "  " : "") + modelData.signal + "%"
                    highlighted: modelData.inUse
                    onClicked: {
                        if (modelData.inUse) {
                            Network.disconnectNetwork(modelData.ssid);
                        } else if (modelData.secure && !modelData.known) {
                            win.asking = modelData;
                            password.text = "";
                            password.forceActiveFocus();
                        } else {
                            win.asking = null;
                            Network.connect(modelData, "");
                        }
                    }
                }
            }

            Txt {
                width: parent.width
                visible: Network.wifiEnabled && Network.networks.length === 0 && !Network.scanning
                text: "No networks found."
                color: Theme.subtext
            }

            // Inline password prompt.
            Column {
                width: parent.width
                spacing: 6
                visible: win.asking !== null

                Txt {
                    width: parent.width
                    text: win.asking ? "Password for " + win.asking.ssid : ""
                }
                Rectangle {
                    width: parent.width
                    height: 34
                    radius: Config.radius
                    color: Theme.surface
                    border.color: Theme.accent
                    border.width: 1

                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.margins: 8
                        echoMode: TextInput.Password
                        color: Theme.text
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        onAccepted: {
                            const net = win.asking;
                            const pw = text;
                            text = "";
                            win.asking = null;
                            if (net) Network.connect(net, pw);
                        }
                    }
                }
                Txt {
                    text: "Enter to connect"
                    color: Theme.subtext
                    font.pixelSize: Config.fontSize - 2
                }
            }

            Txt {
                width: parent.width
                visible: Network.busy
                text: "Connecting…"
                color: Theme.yellow
            }
            Txt {
                width: parent.width
                visible: Network.message !== ""
                wrapMode: Text.WordWrap
                text: Network.message
                color: Theme.red
            }
            Txt {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Enterprise and hidden networks: use nmtui."
                color: Theme.subtext
                font.pixelSize: Config.fontSize - 2
            }
        }
    }
}
