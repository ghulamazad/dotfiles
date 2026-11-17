// "label ........ value" with a thin bar underneath. `fraction` is 0 to 1.
import QtQuick
import qs.config
import qs.themes

Item {
    id: root
    property string label: ""
    property string valueText: ""
    property real fraction: 0
    property color barColor: Theme.accent

    width: parent ? parent.width : Config.px(300)
    height: Config.px(30)

    Txt { anchors.left: parent.left; text: root.label; color: Theme.subtext; font.pixelSize: Config.fontSmall }
    Txt { anchors.right: parent.right; text: root.valueText }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Config.px(4)
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.fraction))
            height: parent.height
            color: root.barColor
        }
    }
}
