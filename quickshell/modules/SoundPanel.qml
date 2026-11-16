// Sound panel: output volume slider, mute and microphone toggles, and the list
// of output devices (click one to make it the default). Same look as the other
// bar panels. UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PopPanel {
        id: win
        required property var modelData
        screen: modelData
        name: "sound"

        // Hardware outputs only (not the per-application streams).
        readonly property var sinks: Array.from(Pipewire.nodes.values)
            .filter(n => n.isSink && !n.isStream && n.audio !== null)

        function label(node) {
            return node.nickname !== "" ? node.nickname : (node.description !== "" ? node.description : node.name);
        }

        PanelHeader { title: "Sound" }

        SectionLabel { text: Audio.available ? "OUTPUT: " + win.label(Audio.sink).toUpperCase() : "NO AUDIO OUTPUT"; width: parent.width }

        Row {
            width: parent.width
            spacing: 10
            visible: Audio.available

            Txt {
                id: volIcon
                width: 24
                height: 22
                horizontalAlignment: Text.AlignHCenter
                text: (Audio.muted || Audio.volume === 0) ? Icons.volumeMuted : Icons.volume(Audio.volume)
                color: Audio.muted ? Theme.red : Theme.text
                font.pixelSize: 16
            }
            Slider {
                width: parent.width - volIcon.width - pct.width - 20
                value: Audio.volume
                onMoved: v => Audio.setVolume(v)
            }
            Txt {
                id: pct
                width: 40
                height: 22
                horizontalAlignment: Text.AlignRight
                text: Math.round(Audio.volume * 100) + "%"
            }
        }

        Divider {}

        Column {
            width: parent.width
            spacing: 8
            SectionLabel { text: "TOGGLES" }
            ToggleRow { label: "Mute"; checked: Audio.muted; onToggled: Audio.toggleMute() }
            ToggleRow { label: "Microphone muted"; visible: Audio.micAvailable; checked: Audio.micMuted; onToggled: Audio.toggleMic() }
        }

        Divider {}

        Column {
            width: parent.width
            spacing: 2
            SectionLabel { text: "OUTPUT DEVICES"; height: 24 }

            Repeater {
                model: win.sinks

                delegate: ListRow {
                    id: row
                    required property var modelData
                    glyph: /headphone|headset/i.test(modelData.name + modelData.description) ? Icons.headphones : Icons.speaker
                    glyphColor: Audio.sink === modelData ? Theme.accent : Theme.text
                    title: win.label(modelData)
                    subtitle: Audio.sink === modelData ? "Default output" : ""
                    highlighted: Audio.sink === modelData
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }

            Txt {
                width: parent.width
                visible: win.sinks.length === 0
                text: "No output devices found."
                color: Theme.subtext
            }
        }
    }
}
