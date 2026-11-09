// Title of the focused window, via the Wayland foreign-toplevel protocol.
import QtQuick
import Quickshell.Wayland
import qs.components
import qs.themes

Txt {
    readonly property var active: ToplevelManager.activeToplevel

    text: active ? active.title : ""
    color: Theme.subtext
    width: Math.min(implicitWidth, 420)
}
