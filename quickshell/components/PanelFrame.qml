// Card that drops down from the bar. Put it inside an Overlay and give it
// `progress: win.progress`. Children are laid out in a padded column.
import QtQuick
import qs.config

Card {
    id: root

    property real progress: 1
    property string align: "right"     // right | center
    property int cardWidth: Config.px(360)
    default property alias content: col.data

    x: align === "center" ? (parent.width - width) / 2 : parent.width - width - Config.px(10)
    y: Config.barHeight + Config.px(8)
    width: cardWidth
    height: col.implicitHeight + Config.px(32)
    opacity: progress
    scale: 0.97 + 0.03 * progress
    transformOrigin: align === "center" ? Item.Top : Item.TopRight

    // Clicks on the card must not fall through to the Overlay's click-to-close.
    MouseArea { anchors.fill: parent }

    Column {
        id: col
        x: Config.px(16)
        y: Config.px(16)
        width: parent.width - Config.px(32)
        spacing: Config.px(12)
    }
}
