// One dropdown panel of the top bar: a full-screen click-to-close layer holding
// a PanelFrame card. Every bar panel (sound, system, battery, clock, tray) is
// this component with its own children, so they all look and behave the same.
//   name:  which UIState.panel value opens it
//   align: "right" (under the right-hand icons) or "center" (under the clock)
// Children go straight into the card's padded column.
import QtQuick
import qs.services
import qs.config

Overlay {
    id: win

    property string name: ""
    property string align: "right"
    property int cardWidth: Config.px(380)
    default property alias body: frame.content

    open: UIState.panel === name
    layerNamespace: "qs-panel"
    onCloseRequested: UIState.closeAll()

    PanelFrame {
        id: frame
        progress: win.progress
        align: win.align
        cardWidth: win.cardWidth
    }
}
