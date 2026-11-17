// Flat horizontal slider. `value` is 0 to 1; `moved(v)` fires while you drag,
// click or scroll. The owner writes the new value back (one source of truth).
import QtQuick
import qs.themes
import qs.config

Item {
    id: root
    property real value: 0
    signal moved(real v)

    width: parent ? parent.width : Config.px(300)
    height: Config.px(22)

    function setFrom(x) { moved(Math.max(0, Math.min(1, x / width))); }

    Rectangle {
        id: track
        width: parent.width
        height: Config.px(4)
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
    }
    Rectangle {
        width: track.width * Math.max(0, Math.min(1, root.value))
        height: Config.px(4)
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.accent
    }
    Rectangle {
        width: Config.px(8)
        height: Config.px(14)
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * Math.max(0, Math.min(1, root.value))
        color: Theme.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.setFrom(mouse.x)
        onPositionChanged: mouse => { if (pressed) root.setFrom(mouse.x); }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
