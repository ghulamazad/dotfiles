// Tray, folded into the bar. Click the ^ icon (first of the right-hand icons): the apps appear to its right and
// shows every tray app (OBS, other GTK and Qt apps...). It folds back by itself
// when focus changes (another window or workspace), when another panel opens,
// or when you click the icon again.
// Left click = the app's main action, middle = secondary, right = its own menu
// (the menu needs `//@ pragma UseQApplication` in shell.qml).
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services
import qs.themes

Row {
    id: root
    spacing: 0

    property bool expanded: false
    readonly property int count: SystemTray.items.values.length

    visible: count > 0
    onCountChanged: if (count === 0) expanded = false

    // Fold back when focus moves elsewhere.
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() { root.expanded = false; }
        function onFocusedWorkspaceChanged() { root.expanded = false; }
    }

    // ...or when any other panel or the launcher opens.
    Connections {
        target: UIState
        function onPanelChanged() { root.expanded = false; }
        function onLauncherChanged() { root.expanded = false; }
        function onWifiChanged() { root.expanded = false; }
        function onBluetoothChanged() { root.expanded = false; }
    }

    BarButton {
        active: root.expanded
        anchors.verticalCenter: parent.verticalCenter
        onClicked: root.expanded = !root.expanded
        Txt { text: root.expanded ? Icons.chevronRight : Icons.chevronLeft; color: Theme.subtext }
    }

    Row {
        id: apps
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        visible: root.expanded

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: entry
                required property var modelData

                // Same visual size as the font icons next to it (font size + 2).
                width: Config.fontSize + 8
                height: Config.barHeight - 4

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Config.fontSize + 2
                    source: entry.modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.MiddleButton) {
                            entry.modelData.secondaryActivate();
                        } else if (event.button === Qt.RightButton || (event.button === Qt.LeftButton && entry.modelData.onlyMenu)) {
                            if (entry.modelData.hasMenu) {
                                const spot = entry.mapToItem(null, 0, entry.height);
                                entry.modelData.display(QsWindow.window, spot.x, spot.y);
                            }
                        } else {
                            entry.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
