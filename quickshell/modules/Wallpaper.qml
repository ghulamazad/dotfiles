// Wallpaper, drawn as a Quickshell background layer on every monitor, so no
// hyprpaper or swaybg process is needed. The file is set in config/Config.qml.
// If it is missing you get the plain theme background.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
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
            // '#' and '?' would otherwise be read as URL fragment/query parts.
            source: "file://" + encodeURI(Config.wallpaper).replace(/[#?]/g, c => encodeURIComponent(c))
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            // Decode at screen size, not the (possibly 8K) source size.
            sourceSize.width: win.width
            sourceSize.height: win.height
        }
    }
}
