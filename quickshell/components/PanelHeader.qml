// Title on the left, optional controls (children) on the right.
import QtQuick

Item {
    id: root
    property string title: ""
    default property alias controls: row.data

    width: parent ? parent.width : 300
    height: 32

    Txt {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.bold: true
        font.pixelSize: 16
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
    }
}
