// A flat clickable area for the top bar. Children are laid out in a Row.
// Wheel events are re-emitted so indicators can react to scrolling.
import QtQuick
import qs.themes
import qs.config

Item {
    id: root

    default property alias content: row.data
    property bool active: false
    signal clicked()
    signal rightClicked()
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + Config.px(14)
    implicitHeight: Config.px(22)

    // Underline while the panel this button opens is showing.
    Rectangle {
        visible: root.active
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: Theme.accent
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Config.px(5)
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
