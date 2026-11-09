// Wallpaper, drawn as a Quickshell background layer on every monitor.
// No hyprpaper/swaybg process is needed. With no wallpaper chosen yet, it
// shows the plain theme background. The choice is stored by scripts/wallpaper.sh.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: Theme.bg
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "qs-wallpaper"

        Image {
            anchors.fill: parent
            visible: Wallpapers.current !== ""
            // '#' and '?' would otherwise be read as URL fragment/query parts.
            source: Wallpapers.current === "" ? ""
                  : "file://" + encodeURI(Wallpapers.current).replace(/[#?]/g, c => encodeURIComponent(c))
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            // Decode at screen size, not the (possibly 8K) source size.
            sourceSize.width: win.width
            sourceSize.height: win.height
        }
    }
}
