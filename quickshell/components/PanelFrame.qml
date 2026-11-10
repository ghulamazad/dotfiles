// Card that drops down from the bar. Put it inside an Overlay and give it
// `progress: win.progress`. Children are laid out in a padded column.
import QtQuick
import qs.config

Card {
    id: root

    property real progress: 1
    property string align: "right"     // right | center
    property int cardWidth: 360
    default property alias content: col.data

    x: align === "center" ? (parent.width - width) / 2 : parent.width - width - 10
    y: Config.barHeight + 8
    width: cardWidth
    height: col.implicitHeight + 32
    opacity: progress
    scale: 0.97 + 0.03 * progress
    transformOrigin: align === "center" ? Item.Top : Item.TopRight

    // Clicks on the card must not fall through to the Overlay's click-to-close.
    MouseArea { anchors.fill: parent }

    Column {
        id: col
        x: 16
        y: 16
        width: parent.width - 32
        spacing: 12
    }
}
