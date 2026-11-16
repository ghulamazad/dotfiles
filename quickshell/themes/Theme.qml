pragma Singleton
// Petrol Lagoon palette (the same hex values as ghostty, tmux, btop and nvim).
import QtQuick
import Quickshell
import qs.config

Singleton {
    readonly property color bg:      "#0c1618"
    readonly property color surface: "#152325"
    readonly property color select:  "#17393d"
    readonly property color surface2: "#17393d"   // hover / active fill (same as select)
    readonly property color border:  "#2a3f42"
    readonly property color text:    "#c2d8d8"
    readonly property color subtext: "#a0b8b8"
    readonly property color muted:   "#4d6467"
    readonly property color accent:  "#35d0c0"
    readonly property color red:     "#e0736e"
    readonly property color green:   "#6cc48e"
    readonly property color yellow:  "#d1b366"

    readonly property string fontFamily: Config.fontFamily
}
