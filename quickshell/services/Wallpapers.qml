pragma Singleton
// Current wallpaper path, read from the state file written by scripts/wallpaper.sh
// (`wallpaper.sh set FILE`). No wallpaper daemon runs: modules/Wallpaper.qml draws it.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string current: ""

    FileView {
        id: store
        path: Config.stateDir + "/wallpaper"
        watchChanges: true
        printErrors: false   // missing before the first choice
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }
}
