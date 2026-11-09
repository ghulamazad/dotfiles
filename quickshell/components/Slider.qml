// Horizontal slider. `value` is shown; user input emits moved(newValue).
// The owner decides what to do with moved(), so this stays side-effect free.
import QtQuick
import qs.themes

Item {
    id: root

    property real value: 0
    property real maximum: 1
    signal moved(real value)

    readonly property real fraction: maximum > 0 ? Math.max(0, Math.min(1, value / maximum)) : 0

    implicitWidth: 180
    implicitHeight: 22

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.surface2

        Rectangle {
            width: parent.width * root.fraction
            height: parent.height
            radius: 3
            color: Theme.accent
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (track.width - width) * root.fraction
        width: 14
        height: 14
        radius: 7
        color: Theme.text
    }

    MouseArea {
        anchors.fill: parent

        function setFromX(mouseX) {
            root.moved(Math.max(0, Math.min(1, mouseX / width)) * root.maximum);
        }

        onPressed: event => setFromX(event.x)
        onPositionChanged: event => { if (pressed) setFromX(event.x); }
        onWheel: wheel => {
            const step = root.maximum * 0.05;
            root.moved(Math.max(0, Math.min(root.maximum, root.value + (wheel.angleDelta.y > 0 ? step : -step))));
        }
    }
}
