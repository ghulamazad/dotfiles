// One line of a TOGGLES section: a label on the left, a switch on the right.
import QtQuick
import qs.themes
import qs.config

Item {
    id: root
    property string label: ""
    property bool checked: false
    signal toggled()

    width: parent ? parent.width : Config.px(300)
    height: Config.px(24)

    Txt { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: root.label }
    Toggle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: root.checked
        onToggled: root.toggled()
    }
}
