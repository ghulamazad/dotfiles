// Full-screen transparent layer that hosts one popup card.
//  * Closes on a click outside the card or on Escape (closeRequested).
//  * Takes keyboard focus only while open, so it never steals typing otherwise.
//  * Appears on the monitor that currently has focus, not on every monitor.
//  * `progress` goes 0 to 1 while opening: use it for fade or scale.
//
// Every Quickshell surface uses a namespace starting with "qs-" so one layer
// rule in hypr/window-rules.lua can blur them all.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool open: false
    property string layerNamespace: "qs-panel"
    default property alias content: holder.data
    property real progress: open ? 1 : 0
    signal closeRequested()

    Behavior on progress { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    readonly property bool onFocusedMonitor: {
        const mon = Hyprland.monitorFor(root.screen);
        return mon === null || Hyprland.focusedMonitor === null || mon === Hyprland.focusedMonitor;
    }

    visible: (open || progress > 0.01) && onFocusedMonitor
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: root.layerNamespace
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
    }

    Item {
        id: holder
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: root.closeRequested()
    }
}
