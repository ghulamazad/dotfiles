pragma Singleton
// Colors and the dark/light switch. The choice is persisted in
// ~/.local/state/dotfiles/theme so it survives restarts and works offline.
// Palette matches ghostty/config (Tokyo Night style).
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool dark: true

    readonly property color bg:       dark ? "#1a1b26" : "#eceff4"
    readonly property color surface:  dark ? "#24283b" : "#ffffff"
    readonly property color surface2: dark ? "#292e42" : "#dfe4ec"
    readonly property color border:   dark ? "#414868" : "#c8ced9"
    readonly property color text:     dark ? "#c0caf5" : "#2e3440"
    readonly property color subtext:  dark ? "#a9b1d6" : "#4c566a"
    readonly property color accent:   "#7aa2f7"
    readonly property color accent2:  "#bb9af7"
    readonly property color red:      "#f7768e"
    readonly property color green:    "#9ece6a"
    readonly property color yellow:   "#e0af68"
    // Omarchy shell surfaces are opaque Tokyo Night background by default.
    readonly property color panel:    dark ? "#1a1b26" : "#eceff4"
    readonly property color scrim:    "#801a1b26"

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
