// Keyboard-first launcher (SUPER+Space). Three modes share one window:
//   apps       live search over installed applications, recents, calculator, power actions
//   clipboard  cliphist history (SUPER+C)
//   wallpapers pick a wallpaper from ~/Pictures/Wallpapers (SUPER+W)
//
// Keys: type to filter, Up/Down to move, Enter to run, Escape to close.
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
        readonly property string mode: UIState.launcherMode

        onShown: input.forceActiveFocus()

        onOpenChanged: {
            if (!open) return;
            query = "";
            selected = 0;
            input.text = "";
            input.forceActiveFocus();
            if (mode === "clipboard") Clipboard.refresh();
            if (mode === "wallpapers") Wallpapers.refresh();
        }

        // ------------------------------------------------------------ helpers
        // Calculator. Only digits, + - * / % ^ ( ) . and spaces may reach eval(),
        // so no identifier or function call can ever be evaluated.
        function calculate(text) {
            if (!/^[0-9+\-*\/%().\s^]+$/.test(text)) return null;
            if (!/[0-9]/.test(text) || !/[+\-*\/%^]/.test(text.replace(/^\s*-/, ""))) return null;
            try {
                const value = eval(text.replace(/\^/g, "**"));
                if (typeof value !== "number" || !isFinite(value)) return null;
                return String(Math.round(value * 1e10) / 1e10);
            } catch (e) {
                return null;
            }
        }

        function launch(entry) {
            Recents.add(entry.id);
            UIState.closeAll();
            if (entry.runInTerminal) {
                Quickshell.execDetached([Config.terminal, "-e"].concat(Array.from(entry.command)));
            } else {
                entry.execute();
            }
        }

        function appResults(q) {
            const out = [];

            const calc = calculate(q);
            if (calc !== null) {
                out.push({
                    title: calc, subtitle: "Calculator, Enter copies the result", glyph: "=",
                    run: () => { UIState.closeAll(); Quickshell.execDetached(["wl-copy", calc]); }
                });
            }

            if (q.length >= 2) {
                for (const action of PowerActions.actions) {
                    if (action.name.toLowerCase().includes(q)) {
                        out.push({
                            title: action.name, subtitle: "Session", glyph: action.glyph,
                            run: () => { UIState.closeAll(); PowerActions.run(action); }
                        });
                    }
                }
            }

            const scored = [];
            for (const entry of Array.from(DesktopEntries.applications.values)) {
                let score = 0;
                if (q !== "") {
                    const name = entry.name.toLowerCase();
                    if (name.startsWith(q)) score = 1;
                    else if (name.includes(q)) score = 2;
                    else if ((entry.genericName || "").toLowerCase().includes(q)
                          || Array.from(entry.keywords).some(k => k.toLowerCase().includes(q))
                          || (entry.comment || "").toLowerCase().includes(q)) score = 3;
                    else continue;
                }
                scored.push({ entry: entry, score: score, recent: Recents.rank(entry.id) });
            }

            scored.sort((a, b) => {
                if (a.score !== b.score) return a.score - b.score;
                const ar = a.recent < 0 ? 99 : a.recent;
                const br = b.recent < 0 ? 99 : b.recent;
                if (ar !== br) return ar - br;
                return a.entry.name.localeCompare(b.entry.name);
            });

            for (const item of scored.slice(0, 60)) {
                out.push({
                    title: item.entry.name,
                    subtitle: item.recent >= 0 && q === "" ? "Recent" : (item.entry.genericName || item.entry.comment || ""),
                    icon: item.entry.icon,
                    run: () => win.launch(item.entry)
                });
            }
            return out;
        }

        function clipboardResults(q) {
            return Clipboard.entries
                .filter(e => q === "" || e.preview.toLowerCase().includes(q))
                .slice(0, 80)
                .map(e => ({
                    title: e.preview, subtitle: "Enter copies it back", glyph: Icons.clipboard,
                    run: () => { UIState.closeAll(); Clipboard.copy(e.id); }
                }));
        }

        function wallpaperResults(q) {
            return Wallpapers.images
                .filter(p => q === "" || p.toLowerCase().includes(q))
                .slice(0, 200)
                .map(p => ({
                    title: p.split("/").pop(),
                    subtitle: "Enter: desktop   Ctrl+Enter: lock screen" + (p === Wallpapers.current ? "   (current)" : ""),
                    glyph: Icons.image,
                    image: p,
                    run: () => { UIState.closeAll(); Wallpapers.choose(p); },
                    runAlt: () => { UIState.closeAll(); Wallpapers.chooseLock(p); }
                }));
        }

        readonly property var results: {
            const q = query.trim().toLowerCase();
            if (mode === "clipboard") return clipboardResults(q);
            if (mode === "wallpapers") return wallpaperResults(q);
            return appResults(q);
        }

        // Ctrl+Enter runs the entry's alternative action, if it has one
        // (wallpapers: set the lock screen image instead of the desktop one).
        function activate(alt) {
            if (results.length === 0 || selected < 0 || selected >= results.length) return;
            const entry = results[selected];
            if (alt && entry.runAlt) entry.runAlt();
            else entry.run();
        }

        // --------------------------------------------------------------- view
        Card {
            id: card
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.16
            width: 640
            height: 56 + Math.min(win.results.length, 8) * 46 + 24
            opacity: win.progress
            scale: 0.97 + 0.03 * win.progress

            Behavior on height { NumberAnimation { duration: 100 } }

            MouseArea { anchors.fill: parent }

            Row {
                id: header
                x: 18
                y: 14
                height: 28
                spacing: 12

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.mode === "clipboard" ? Icons.clipboard : win.mode === "wallpapers" ? Icons.image : Icons.search
                    font.pixelSize: 17
                    color: Theme.accent
                }

                Item {
                    width: card.width - 80
                    height: parent.height

                    TextInput {
                        id: input
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        selectionColor: Theme.accent
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize + 3
                        clip: true

                        onTextChanged: {
                            win.query = text;
                            win.selected = 0;
                        }
                        Keys.onDownPressed: win.selected = Math.min(win.selected + 1, win.results.length - 1)
                        Keys.onUpPressed: win.selected = Math.max(win.selected - 1, 0)
                        Keys.onReturnPressed: event => win.activate(event.modifiers & Qt.ControlModifier)
                        Keys.onEnterPressed: event => win.activate(event.modifiers & Qt.ControlModifier)
                        // Vim/readline-style movement: Ctrl+N or Ctrl+J down, Ctrl+P or Ctrl+K up.
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
                        text: win.mode === "clipboard" ? "Search clipboard history"
                            : win.mode === "wallpapers" ? "Search wallpapers"
                            : "Search apps, calculate, or type a power action"
                        font.pixelSize: Config.fontSize + 3
                        color: Theme.subtext
                    }
                }
            }

            ListView {
                id: list
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 12
                anchors.topMargin: 14
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
                    height: 46
                    radius: Config.radius
                    color: index === win.selected ? Theme.surface2 : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 12

                        // Application icon from the system icon theme.
                        IconImage {
                            visible: row.modelData.icon !== undefined
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 28
                            source: row.modelData.icon !== undefined
                                ? Quickshell.iconPath(row.modelData.icon, "application-x-executable") : ""
                        }

                        // Wallpaper thumbnail, decoded small.
                        Image {
                            visible: row.modelData.image !== undefined
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            height: 28
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 88
                            sourceSize.height: 56
                            source: row.modelData.image !== undefined
                                ? "file://" + encodeURI(row.modelData.image).replace(/[#?]/g, c => encodeURIComponent(c)) : ""
                        }

                        // Glyph for non-application results.
                        Txt {
                            visible: row.modelData.glyph !== undefined
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            horizontalAlignment: Text.AlignHCenter
                            text: row.modelData.glyph !== undefined ? row.modelData.glyph : ""
                            font.pixelSize: 17
                            color: Theme.accent
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Txt {
                                text: row.modelData.title
                                width: card.width - 130
                            }
                            Txt {
                                visible: row.modelData.subtitle !== ""
                                text: row.modelData.subtitle
                                font.pixelSize: Config.fontSize - 2
                                color: Theme.subtext
                                width: card.width - 130
                            }
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
