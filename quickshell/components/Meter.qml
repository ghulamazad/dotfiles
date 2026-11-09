// Labeled horizontal usage bar (0.0 to 1.0).
import QtQuick
import qs.config
import qs.themes

Column {
    id: root

    property string label: ""
    property string valueText: ""
    property real fraction: 0
    property color barColor: Theme.accent

    spacing: 4

    Item {
        width: root.width
        height: label.implicitHeight

        Txt { id: label; text: root.label; color: Theme.subtext }
        Txt { anchors.right: parent.right; text: root.valueText }
    }

    Rectangle {
        width: root.width
        height: 6
        radius: 3
        color: Theme.surface2

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.fraction))
            height: parent.height
            radius: 3
            color: root.fraction > 0.9 ? Theme.red : root.barColor

            Behavior on width { NumberAnimation { duration: 200 } }
        }
    }
}
