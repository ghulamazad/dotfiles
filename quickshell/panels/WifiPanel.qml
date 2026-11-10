// Wi-Fi: on/off, list of nearby networks, connect. New secured networks ask
// for a password in this panel; it goes to NetworkManager through a private
// file, never a command line (see services/Network.qml). UNTESTED at runtime.
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

        onOpenChanged: {
            if (open) {
                asking = null;
                password.text = "";
                Network.refresh();
                Network.scan();
            }
        }

        PanelFrame {
            progress: win.progress

            PanelHeader {
                title: "Wi-Fi"
                BarButton {
                    visible: Network.wifiEnabled
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
                height: Math.min(contentHeight, 272)
                visible: Network.wifiEnabled
                clip: true
                spacing: 2
                model: Network.networks

                delegate: ListRow {
                    id: row
                    required property var modelData
                    glyph: Icons.wifi
                    glyphColor: modelData.inUse ? Theme.green : Theme.text
                    title: modelData.ssid
                    subtitle: modelData.inUse ? "Connected"
                        : modelData.known ? "Saved"
                        : modelData.secure ? "Secured" : "Open"
                    trailing: modelData.signal + "%"
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
                    radius: 8
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
