// System tray (StatusNotifierItem). Left click = primary action, middle =
// secondary, right = the app's own menu.
//
// The right-click menu is a platform menu and needs `//@ pragma UseQApplication`
// in shell.qml (Quickshell logs an error without it; checked in its source).
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Row {
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: entry
            required property var modelData

            width: 22
            height: 22

            IconImage {
                anchors.centerIn: parent
                implicitSize: 18
                source: entry.modelData.icon
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
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
