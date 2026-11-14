pragma Singleton
// Clipboard history from `cliphist`, which hypr/autostart.lua feeds through
// `wl-paste --watch`. Everything stays local; nothing is sent anywhere.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []   // { id, preview }, newest first

    function refresh() { list.running = true; }

    // Re-copy an entry. The id comes from cliphist's own output, and is checked
    // to be digits only. It is passed as a positional argument ($1), never
    // spliced into the shell string.
    function copy(id) {
        const clean = String(id);
        if (!/^[0-9]+$/.test(clean)) return;
        Quickshell.execDetached(["sh", "-c",
            "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "sh", clean]);
    }

    function clearAll() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    // `cliphist list` prints: <id><TAB><preview>
    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab > 0) out.push({ id: line.slice(0, tab), preview: line.slice(tab + 1) });
                    if (out.length >= 200) break;
                }
                root.entries = out;
            }
        }
    }
}
