// Keyboard-first launcher. Two modes share one window:
//   apps   SUPER+Space or the bar logo: search installed applications
//   power  SUPER+Escape: lock, log out, suspend, reboot, power off
//
// Keys: type to filter, Up/Down (or Ctrl+N/Ctrl+P) to move, Enter to run,
// Escape to close. Reboot, power off and log out need Enter twice.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
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

        open: UIState.launcher
        layerNamespace: "qs-launcher"
        onCloseRequested: UIState.closeAll()

        property string query: ""
        property int selected: 0
        property string armed: ""          // id of a destructive action waiting for a second Enter
        readonly property string mode: UIState.launcherMode

        onShown: input.forceActiveFocus()
        onSelectedChanged: armed = ""

        onOpenChanged: {
            if (!open) return;
            query = "";
            selected = 0;
            armed = "";
            input.text = "";
            input.forceActiveFocus();
        }

        function appResults(q) {
            const scored = [];
            for (const entry of Array.from(DesktopEntries.applications.values)) {
                let score = 0;
                if (q !== "") {
                    const name = entry.name.toLowerCase();
                    if (name.startsWith(q)) score = 1;
                    else if (name.includes(q)) score = 2;
                    else if ((entry.genericName || "").toLowerCase().includes(q)
                          || Array.from(entry.keywords).some(k => k.toLowerCase().includes(q))) score = 3;
                    else continue;
                }
                scored.push({ entry: entry, score: score });
            }
            scored.sort((a, b) => a.score !== b.score ? a.score - b.score : a.entry.name.localeCompare(b.entry.name));

            return scored.slice(0, 60).map(item => ({
                title: item.entry.name,
                subtitle: item.entry.genericName || item.entry.comment || "",
                icon: item.entry.icon,
                run: () => {
                    UIState.closeAll();
                    if (item.entry.runInTerminal)
                        Quickshell.execDetached([Config.terminal, "-e"].concat(Array.from(item.entry.command)));
                    else
                        item.entry.execute();
                }
            }));
        }

        function powerResults(q) {
            return PowerActions.actions
                .filter(a => q === "" || a.name.toLowerCase().includes(q))
                .map(a => ({
                    title: a.name,
                    subtitle: win.armed === a.id ? "Press Enter again to confirm" : "",
                    glyph: a.glyph,
                    run: () => {
                        if (a.confirm && win.armed !== a.id) { win.armed = a.id; return; }
                        UIState.closeAll();
                        PowerActions.run(a);
                    }
                }));
        }

        readonly property var results: {
            const q = query.trim().toLowerCase();
            return mode === "power" ? powerResults(q) : appResults(q);
        }

        function activate() {
            if (results.length === 0 || selected < 0 || selected >= results.length) return;
            results[selected].run();
        }

        Card {
            id: card
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.16
            width: Config.px(560)
            height: Config.px(52) + Math.min(win.results.length, 8) * Config.px(40) + Config.px(20)
            opacity: win.progress

            MouseArea { anchors.fill: parent }

            Row {
                id: header
                x: Config.px(16)
                y: Config.px(12)
                height: Config.px(28)
                spacing: Config.px(12)

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.mode === "power" ? Icons.power : Icons.search
                    font.pixelSize: Config.px(16)
                    color: Theme.accent
                }

                Item {
                    width: card.width - Config.px(76)
                    height: parent.height

                    TextInput {
                        id: input
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        selectionColor: Theme.accent
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontLarge
                        clip: true

                        onTextChanged: {
                            win.query = text;
                            win.selected = 0;
                        }
                        Keys.onDownPressed: win.selected = Math.min(win.selected + 1, win.results.length - 1)
                        Keys.onUpPressed: win.selected = Math.max(win.selected - 1, 0)
                        Keys.onReturnPressed: win.activate()
                        Keys.onEnterPressed: win.activate()
                        // Readline-style movement: Ctrl+N or Ctrl+J down, Ctrl+P or Ctrl+K up.
                        Keys.onPressed: event => {
                            if (!(event.modifiers & Qt.ControlModifier)) return;
                            if (event.key === Qt.Key_N || event.key === Qt.Key_J) {
                                win.selected = Math.min(win.selected + 1, win.results.length - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_P || event.key === Qt.Key_K) {
                                win.selected = Math.max(win.selected - 1, 0);
                                event.accepted = true;
                            }
                        }
                    }

                    Txt {
                        anchors.fill: parent
                        visible: input.text === ""
                        text: win.mode === "power" ? "Session" : "Search applications"
                        font.pixelSize: Config.fontLarge
                        color: Theme.muted
                    }
                }
            }

            ListView {
                id: list
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 10
                anchors.topMargin: 12
                clip: true
                model: win.results
                currentIndex: win.selected
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index

                    width: list.width
                    height: Config.px(40)
                    color: index === win.selected ? Theme.select : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: Config.px(12)

                        IconImage {
                            visible: row.modelData.icon !== undefined
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: Config.px(24)
                            source: row.modelData.icon !== undefined
                                ? Quickshell.iconPath(row.modelData.icon, "application-x-executable") : ""
                        }

                        Txt {
                            visible: row.modelData.glyph !== undefined
                            anchors.verticalCenter: parent.verticalCenter
                            width: Config.px(24)
                            horizontalAlignment: Text.AlignHCenter
                            text: row.modelData.glyph !== undefined ? row.modelData.glyph : ""
                            font.pixelSize: Config.px(15)
                            color: Theme.accent
                        }

                        Txt {
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.title
                            width: Config.px(200)
                        }
                        Txt {
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.subtitle
                            font.pixelSize: Config.fontSmall
                            color: row.modelData.subtitle === "Press Enter again to confirm" ? Theme.yellow : Theme.subtext
                            width: card.width - Config.px(20 + 10 + 24 + 24 + 200 + 24)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: win.selected = row.index
                        onClicked: row.modelData.run()
                    }
                }
            }
        }
    }
}
