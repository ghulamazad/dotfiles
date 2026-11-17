// Notification popups, top right under the bar. Quickshell is the only
// notification daemon: do not run mako, dunst or swaync alongside it.
//
// * Click the X to dismiss; action buttons invoke the app's action.
// * Normal notifications expire on their own; Critical ones stay until dismissed.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        readonly property bool onFocusedMonitor: {
            const mon = Hyprland.monitorFor(win.screen);
            return mon === null || Hyprland.focusedMonitor === null || mon === Hyprland.focusedMonitor;
        }

        // The window is only as big as the popups, so it never blocks clicks elsewhere.
        visible: Notifs.popups.values.length > 0 && onFocusedMonitor
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: Config.px(380)
        implicitHeight: stack.implicitHeight

        anchors {
            top: true
            right: true
        }
        margins {
            top: Config.barHeight + Config.px(8)
            right: Config.px(10)
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notify"

        Column {
            id: stack
            width: parent.width
            spacing: Config.px(8)

            Repeater {
                model: Notifs.popups

                delegate: Card {
                    id: popup
                    required property var modelData   // a Notification

                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

                    width: stack.width
                    height: body.implicitHeight + Config.px(24)
                    border.color: critical ? Theme.red : Theme.border

                    // expireTimeout is in seconds; 0 or less means "server default".
                    Timer {
                        interval: (popup.modelData.expireTimeout > 0 ? popup.modelData.expireTimeout : 6) * 1000
                        running: !popup.critical && !hover.containsMouse
                        onTriggered: popup.modelData.expire()
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Row {
                        id: body
                        x: Config.px(12)
                        y: Config.px(12)
                        spacing: Config.px(12)

                        IconImage {
                            visible: source !== ""
                            implicitSize: Config.px(40)
                            source: popup.modelData.image !== "" ? popup.modelData.image
                                  : popup.modelData.appIcon === "" ? ""
                                  : popup.modelData.appIcon.startsWith("/") ? "file://" + popup.modelData.appIcon
                                  : Quickshell.iconPath(popup.modelData.appIcon, true)
                        }

                        Column {
                            width: popup.width - Config.px(24 + 12 + 40 + 28)
                            spacing: Config.px(3)

                            Txt {
                                width: parent.width
                                text: popup.modelData.appName
                                font.pixelSize: Config.fontSmall
                                color: Theme.subtext
                            }
                            Txt {
                                width: parent.width
                                text: popup.modelData.summary
                                font.bold: true
                            }
                            Txt {
                                visible: text !== ""
                                width: parent.width
                                text: popup.modelData.body
                                textFormat: Text.PlainText
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                color: Theme.subtext
                            }

                            Row {
                                spacing: Config.px(6)
                                visible: popup.modelData.actions.length > 0

                                Repeater {
                                    model: popup.modelData.actions
                                    delegate: BarButton {
                                        required property var modelData
                                        onClicked: {
                                            modelData.invoke();
                                            popup.modelData.dismiss();
                                        }
                                        Txt { text: parent.parent.modelData.text; color: Theme.accent }
                                    }
                                }
                            }
                        }
                    }

                    BarButton {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        onClicked: popup.modelData.dismiss()
                        Txt { text: Icons.close; font.pixelSize: Config.px(12); color: Theme.subtext }
                    }
                }
            }
        }
    }
}
