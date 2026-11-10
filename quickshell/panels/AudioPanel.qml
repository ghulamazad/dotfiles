// Speaker: volume, mute, microphone mute and the choice of output device.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    Overlay {
        id: win
        required property var modelData
        screen: modelData

        open: UIState.audio
        layerNamespace: "qs-panel"
        onCloseRequested: UIState.closeAll()

        PanelFrame {
            progress: win.progress

            PanelHeader {
                title: "Sound"
                BarButton {
                    visible: Audio.micAvailable
                    active: Audio.micMuted
                    onClicked: Audio.toggleMic()
                    Txt { text: Audio.micMuted ? "Mic muted" : "Mic on"; color: Audio.micMuted ? Theme.red : Theme.text }
                }
                BarButton {
                    visible: Audio.available
                    active: Audio.muted
                    onClicked: Audio.toggleMute()
                    Txt { text: Audio.muted ? "Muted" : "Mute"; color: Audio.muted ? Theme.red : Theme.text }
                }
            }

            Txt {
                width: parent.width
                visible: !Audio.available
                wrapMode: Text.WordWrap
                text: "No audio output. Is PipeWire running? (wpctl status)"
                color: Theme.subtext
            }

            Row {
                width: parent.width
                spacing: 10
                visible: Audio.available

                Txt {
                    width: 24
                    horizontalAlignment: Text.AlignHCenter
                    text: (Audio.muted || Audio.volume === 0) ? Icons.volumeOff
                        : Audio.volume < 0.5 ? Icons.volumeLow : Icons.volumeHigh
                    font.pixelSize: 16
                }
                Slider {
                    width: parent.width - 24 - 44 - 20
                    anchors.verticalCenter: parent.verticalCenter
                    value: Audio.volume
                    maximum: 1.0
                    onMoved: v => Audio.setVolume(v)
                }
                Txt {
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(Audio.volume * 100) + "%"
                    color: Theme.subtext
                }
            }

            Txt {
                visible: Audio.sinks.length > 1
                text: "Output"
                color: Theme.subtext
            }

            Column {
                width: parent.width
                spacing: 2
                visible: Audio.sinks.length > 1

                Repeater {
                    model: Audio.sinks
                    delegate: ListRow {
                        required property var modelData
                        glyph: Icons.volumeHigh
                        title: Audio.describe(modelData)
                        trailing: modelData === Audio.sink ? Icons.check : ""
                        highlighted: modelData === Audio.sink
                        onClicked: Audio.setDefaultSink(modelData)
                    }
                }
            }
        }
    }
}
