// Notification history (SUPER+N or the bell in the bar). Shows the last 50
// notifications received this session, including ones that already expired.
// History lives in memory only and is cleared when Quickshell restarts.
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

        open: UIState.notificationCenter
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        Card {
            anchors.right: parent.right
            anchors.rightMargin: 10
            y: Config.barHeight + 8
            width: 400
            height: Math.min(parent.height - Config.barHeight - 30, 520)
            opacity: win.progress
            scale: 0.97 + 0.03 * win.progress
            transformOrigin: Item.TopRight

            MouseArea { anchors.fill: parent }

            Item {
                id: head
                x: 16
                y: 14
                width: parent.width - 32
                height: 30

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications"
                    font.bold: true
                    font.pixelSize: Config.fontSize + 2
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    BarButton {
                        active: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                        Txt { text: Notifs.dnd ? Icons.bellOff : Icons.bell; color: Notifs.dnd ? Theme.yellow : Theme.text }
                        Txt { text: Notifs.dnd ? "DND on" : "DND off" }
                    }
                    BarButton {
                        onClicked: { Notifs.dismissAll(); Notifs.clearHistory(); }
                        Txt { text: Icons.trash; color: Theme.subtext }
                        Txt { text: "Clear" }
                    }
                }
            }

            Txt {
                anchors.centerIn: parent
                visible: Notifs.history.length === 0
                text: "No notifications"
                color: Theme.subtext
            }

            ListView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: head.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 16
                clip: true
                spacing: 8
                model: Notifs.history
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: item
                    required property var modelData

                    width: ListView.view.width
                    height: col.implicitHeight + 20
                    radius: Config.radius
                    color: Theme.surface

                    Column {
                        id: col
                        x: 12
                        y: 10
                        width: parent.width - 24
                        spacing: 2

                        Txt {
                            width: parent.width
                            text: item.modelData.appName + "   " + Qt.formatDateTime(item.modelData.time, "HH:mm")
                            font.pixelSize: Config.fontSize - 2
                            color: Theme.subtext
                        }
                        Txt { width: parent.width; text: item.modelData.summary; font.bold: true }
                        Txt {
                            visible: text !== ""
                            width: parent.width
                            text: item.modelData.body
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            color: Theme.subtext
                        }
                    }
                }
            }
        }
    }
}
