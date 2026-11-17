// Thin horizontal line between sections of a panel.
import QtQuick
import qs.themes

Rectangle {
    width: parent ? parent.width : Config.px(300)
    height: 1
    color: Theme.border
}
