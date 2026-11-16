// Small text button for a row of choices. `count` is how many share the row.
import QtQuick
import qs.config
import qs.themes

Rectangle {
    id: choice
    property string label: ""
    property bool active: false
    property int count: 3
    signal clicked()

    width: (parent.width - (count - 1) * parent.spacing) / count
    height: 34
    radius: Config.radius
    color: (active || m.containsMouse) ? Theme.surface2 : "transparent"
    border.color: active ? Theme.accent : Theme.border
    border.width: 1

    Txt { anchors.centerIn: parent; text: choice.label; color: choice.active ? Theme.accent : Theme.text }

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: choice.clicked()
    }
}
