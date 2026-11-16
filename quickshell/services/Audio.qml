pragma Singleton
// Default output volume and mute through PipeWire (Quickshell.Services.Pipewire).
// The hardware keys in hypr/bindings.lua use wpctl; both talk to the same server.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.audio !== null
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false

    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool micAvailable: source !== null && source.audio !== null
    readonly property bool micMuted: micAvailable ? source.audio.muted : false
    function toggleMic() {
        if (micAvailable) source.audio.muted = !source.audio.muted;
    }

    function setVolume(value) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1.0, value));
    }
    function toggleMute() {
        if (available) sink.audio.muted = !sink.audio.muted;
    }

    // Audio properties are only valid while the node is tracked (Quickshell docs).
    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
