pragma Singleton
// Colors and the dark/light switch. The choice is persisted in
// ~/.local/state/dotfiles/theme so it survives restarts and works offline.
// Palette: Tokyo Night Night — values from /usr/share/omarchy/themes/tokyo-night/colors.toml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool dark: true

    readonly property color bg:       dark ? "#1a1b26" : "#eceff4"
    readonly property color surface:  dark ? "#24283b" : "#ffffff"
    // surface2 = dark olive/green for selected rows (##-heading bar look from screenshot)
    readonly property color surface2: dark ? "#1a2a1a" : "#dfe4ec"
    readonly property color border:   dark ? "#414868" : "#c8ced9"
    readonly property color text:     dark ? "#a9b1d6" : "#2e3440"
    readonly property color subtext:  dark ? "#565f89" : "#4c566a"
    readonly property color accent:   "#7aa2f7"
    readonly property color accent2:  "#9ece6a"
    readonly property color red:      "#f7768e"
    readonly property color green:    "#9ece6a"
    readonly property color yellow:   "#e0af68"
    // Tokyo Night Night opaque panel background
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
