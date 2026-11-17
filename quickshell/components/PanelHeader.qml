// Title on the left, optional controls (children) on the right.
import QtQuick
import qs.config

Item {
    id: root
    property string title: ""
    default property alias controls: row.data

    width: parent ? parent.width : Config.px(300)
    height: Config.px(32)

    Txt {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.bold: true
        font.pixelSize: Config.px(16)
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.px(6)
    }
}
