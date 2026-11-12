// A clickable pill for the top bar. Children are laid out in a Row.
import QtQuick
import qs.config
import qs.themes

Rectangle {
    id: root

    default property alias content: row.data
    property bool active: false
    signal clicked()
    signal rightClicked()

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 24
    radius: Config.radius
    color: (mouse.containsMouse || active) ? Theme.surface2 : "transparent"

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}
