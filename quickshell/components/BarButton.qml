// A flat clickable area for the top bar. Children are laid out in a Row.
// Wheel events are re-emitted so indicators can react to scrolling.
import QtQuick
import qs.themes

Item {
    id: root

    default property alias content: row.data
    property bool active: false
    signal clicked()
    signal rightClicked()
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + 14
    implicitHeight: 22

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }
}
