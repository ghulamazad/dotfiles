pragma Singleton
// Wallpaper list and current choice. The choice lives in a plain state file
// written by scripts/wallpaper.sh, so the keybinding, the picker and a shell
// prompt can all change it. No wallpaper daemon runs: modules/Wallpaper.qml
// draws it as a Quickshell background layer.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string current: ""
    property var images: []

    function refresh() { lister.running = true; }

    function choose(path) {
        Quickshell.execDetached([Config.scriptsDir + "/wallpaper.sh", "set", path]);
        // The state file may not exist yet, so a file watcher could miss its
        // creation. Re-read explicitly shortly after writing.
        recheck.restart();
    }

    Timer { id: recheck; interval: 400; onTriggered: store.reload() }

    FileView {
        id: store
        path: Config.stateDir + "/wallpaper"
        watchChanges: true
        printErrors: false   // missing before the first choice
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }

    Process {
        id: lister
        command: [Config.scriptsDir + "/wallpaper.sh", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.images = text.split("\n").filter(line => line.length > 0)
        }
    }
}
