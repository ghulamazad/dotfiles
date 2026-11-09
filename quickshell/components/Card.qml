// Rounded translucent container used by every popup.
import QtQuick
import qs.config
import qs.themes

Rectangle {
    color: Theme.panel
    radius: Config.radius + 4
    border.color: Theme.border
    border.width: 1
}
