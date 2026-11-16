// Themed text. Use everywhere instead of bare Text so font and color stay consistent.
import QtQuick
import qs.config
import qs.themes

Text {
    color: Theme.text
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
