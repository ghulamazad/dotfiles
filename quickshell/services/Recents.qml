pragma Singleton
// Recently launched applications, newest first, kept in
// ~/.local/state/dotfiles/recent-apps as a JSON array of desktop entry ids.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property var ids: []

    function add(id) {
        if (!id) return;
        ids = [id].concat(ids.filter(x => x !== id)).slice(0, 12);
        store.setText(JSON.stringify(ids) + "\n");
    }

    // Position in the recent list, or -1.
    function rank(id) { return ids.indexOf(id); }

    FileView {
        id: store
        path: Config.stateDir + "/recent-apps"
        printErrors: false
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                if (Array.isArray(parsed)) root.ids = parsed.filter(x => typeof x === "string");
            } catch (e) {
                root.ids = [];
            }
        }
    }
}
