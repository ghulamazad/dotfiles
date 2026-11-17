// On/off switch: a flat pill that fills with the accent colour when on.
import QtQuick
import qs.config
import qs.themes

Rectangle {
    id: sw
    property bool checked: false
    signal toggled()

    width: Config.px(38)
    height: Config.px(18)
    radius: Config.radius
    color: checked ? Theme.accent : Theme.surface
    border.color: checked ? Theme.accent : Theme.border
    border.width: 1

    Rectangle {
        width: Config.px(12)
        height: Config.px(12)
        radius: Config.radius
        anchors.verticalCenter: parent.verticalCenter
        x: sw.checked ? parent.width - width - 3 : 3
        color: sw.checked ? Theme.bg : Theme.muted
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: sw.toggled()
    }
}
