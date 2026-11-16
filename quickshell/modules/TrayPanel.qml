// Tray panel: the "collapsed icon" for other apps (OBS, network managers,
// chat clients, anything with a StatusNotifier tray icon). Left click = the
// app's main action, right click = its own menu, middle click = secondary action.
// Right-click menus need `//@ pragma UseQApplication` in shell.qml.
// UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PopPanel {
        id: win
        required property var modelData
        screen: modelData
        name: "tray"
        cardWidth: 320

        PanelHeader { title: "Apps" }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: SystemTray.items

                delegate: ListRow {
                    id: row
                    required property var modelData
                    iconSource: modelData.icon
                    title: modelData.tooltipTitle !== "" ? modelData.tooltipTitle
                         : (modelData.title !== "" ? modelData.title : modelData.id)
                    subtitle: modelData.hasMenu ? "Right-click for menu" : ""

                    onClicked: {
                        if (modelData.onlyMenu && modelData.hasMenu) openMenu();
                        else { modelData.activate(); UIState.closeAll(); }
                    }
                    onRightClicked: if (modelData.hasMenu) openMenu()

                    function openMenu() {
                        const spot = row.mapToItem(null, row.width / 2, row.height);
                        modelData.display(QsWindow.window, spot.x, spot.y);
                    }
                }
            }
        }

        Txt {
            width: parent.width
            visible: SystemTray.items.values.length === 0
            text: "No apps in the tray."
            color: Theme.subtext
        }
    }
}
