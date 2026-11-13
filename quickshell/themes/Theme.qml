pragma Singleton
// Colors and the dark/light switch. The choice is persisted in
// ~/.local/state/dotfiles/theme so it survives restarts and works offline.
// Palette: Petrol Lagoon (see docs/theme.md). Light mode keeps a neutral light set.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool dark: true

    readonly property color bg:       dark ? "#0c1618" : "#eceff4"
    readonly property color surface:  dark ? "#152325" : "#ffffff"
    readonly property color surface2: dark ? "#17393d" : "#dfe4ec"
    readonly property color border:   dark ? "#2a3f42" : "#c8ced9"
    readonly property color text:     dark ? "#c2d8d8" : "#2e3440"
    readonly property color subtext:  dark ? "#a0b8b8" : "#4c566a"
    readonly property color accent:   "#35d0c0"
    readonly property color accent2:  "#8adaa8"
    readonly property color red:      "#e0736e"
    readonly property color green:    "#6cc48e"
    readonly property color yellow:   "#d1b366"
    // Opaque panel background (same as bg in dark mode)
    readonly property color panel:    dark ? "#0c1618" : "#eceff4"
    readonly property color scrim:    "#800c1618"

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
