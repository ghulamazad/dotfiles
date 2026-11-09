// GNOME-style quick settings tile: glyph, title, optional subtitle.
import QtQuick
import qs.config
import qs.themes

Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool usable: true      // false = greyed out and not clickable
    signal clicked()

    implicitWidth: 160
    implicitHeight: 56
    radius: Config.radius
    color: active ? Theme.accent : Theme.surface2
    opacity: usable ? 1 : 0.45

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        spacing: 12

        Txt {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            font.pixelSize: 18
            color: root.active ? Theme.bg : Theme.text
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Txt {
                text: root.title
                font.bold: true
                color: root.active ? Theme.bg : Theme.text
                width: root.width - 70
            }
            Txt {
                visible: root.subtitle !== ""
                text: root.subtitle
                font.pixelSize: Config.fontSize - 2
                color: root.active ? Theme.bg : Theme.subtext
                width: root.width - 70
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.usable
        onClicked: root.clicked()
    }
}
