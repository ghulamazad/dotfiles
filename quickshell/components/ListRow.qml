// One clickable row: glyph, title, small subtitle, optional trailing text.
import QtQuick
import Quickshell.Widgets
import qs.config
import qs.themes

Rectangle {
    id: root

    property string glyph: ""
    property string iconSource: ""     // an app icon; replaces the glyph when set
    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property bool highlighted: false
    property color glyphColor: Theme.text
    signal clicked()
    signal rightClicked()

    width: parent ? parent.width : Config.px(300)
    height: Config.px(44)
    color: mouse.containsMouse ? Theme.select : (highlighted ? Theme.surface : "transparent")

    Txt {
        id: icon
        x: Config.px(10)
        width: Config.px(24)
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        visible: root.iconSource === ""
        text: root.glyph
        color: root.glyphColor
        font.pixelSize: Config.px(16)
    }

    IconImage {
        x: Config.px(14)
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: Config.px(18)
        visible: root.iconSource !== ""
        source: root.iconSource
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: tail.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        Txt { width: parent.width; text: root.title }
        Txt {
            width: parent.width
            visible: root.subtitle !== ""
            text: root.subtitle
            color: Theme.subtext
            font.pixelSize: Config.fontSmall
        }
    }

    Txt {
        id: tail
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: implicitWidth
        text: root.trailing
        color: Theme.subtext
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => { if (event.button === Qt.RightButton) root.rightClicked(); else root.clicked(); }
    }
}
