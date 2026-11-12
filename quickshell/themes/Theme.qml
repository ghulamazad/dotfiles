pragma Singleton
// Colors and the dark/light switch. The choice is persisted in
// ~/.local/state/dotfiles/theme so it survives restarts and works offline.
// Palette matches the obsidian plum & sage jade reference theme.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool dark: true

    readonly property color bg:       dark ? "#150f1d" : "#eceff4"
    readonly property color surface:  dark ? "#1e1727" : "#ffffff"
    readonly property color surface2: dark ? "#2b5147" : "#dfe4ec"
    readonly property color border:   dark ? "#31343d" : "#c8ced9"
    readonly property color text:     dark ? "#c6bdce" : "#2e3440"
    readonly property color subtext:  dark ? "#8f8498" : "#4c566a"
    readonly property color accent:   "#7db6a7"
    readonly property color accent2:  "#9fbc79"
    readonly property color red:      "#d88d91"
    readonly property color green:    "#81beae"
    readonly property color yellow:   "#d7ba7d"
    // Deep obsidian-plum opaque background matching theme aesthetic
    readonly property color panel:    dark ? "#150f1d" : "#eceff4"
    readonly property color scrim:    "#80150f1d"

    readonly property string fontFamily: Config.fontFamily

    function setDark(value) {
        dark = value;
        store.setText(value ? "dark\n" : "light\n");
        // GNOME-style integration: GTK4/libadwaita apps follow this setting.
        // Fixed argument list, no shell involved. Harmless if gsettings is absent.
        Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface",
                                 "color-scheme", value ? "prefer-dark" : "prefer-light"]);
    }

    // The state directory must exist before the first write.
    Process {
        command: ["mkdir", "-p", Config.stateDir]
        running: true
    }

    FileView {
        id: store
        path: Config.stateDir + "/theme"
        printErrors: false   // missing on first run is normal
        onLoaded: root.dark = (text().trim() !== "light")
    }
}
