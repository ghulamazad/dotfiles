pragma Singleton
// Colors and the dark/light switch. The choice is persisted in
// ~/.local/state/dotfiles/theme so it survives restarts and works offline.
// Palette matches kitty/kitty.conf (Tokyo Night style).
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool dark: true

    readonly property color bg:       dark ? "#14161b" : "#eceff4"
    readonly property color surface:  dark ? "#1c1f26" : "#ffffff"
    readonly property color surface2: dark ? "#2a2f3a" : "#dfe4ec"
    readonly property color border:   dark ? "#3b4252" : "#c8ced9"
    readonly property color text:     dark ? "#d8dee9" : "#2e3440"
    readonly property color subtext:  dark ? "#a9b1d6" : "#4c566a"
    readonly property color accent:   "#7aa2f7"
    readonly property color accent2:  "#bb9af7"
    readonly property color red:      "#f7768e"
    readonly property color green:    "#9ece6a"
    readonly property color yellow:   "#e0af68"
    // Slightly translucent so Hyprland's layer blur (hypr/window-rules.lua) shows through.
    readonly property color panel:    dark ? "#ee14161b" : "#eeeceff4"
    readonly property color scrim:    "#66000000"

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
