pragma Singleton
// Output volume and microphone mute through PipeWire (Quickshell.Services.Pipewire).
// No external commands: the keybindings in hypr/keybindings.lua use wpctl for
// the hardware keys, and both talk to the same PipeWire server.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool available: sink !== null && sink.audio !== null
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false
    readonly property bool micAvailable: source !== null && source.audio !== null
    readonly property bool micMuted: micAvailable ? source.audio.muted : false

    function setVolume(value) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1.5, value));
    }
    function toggleMute() {
        if (available) sink.audio.muted = !sink.audio.muted;
    }
    function toggleMic() {
        if (micAvailable) source.audio.muted = !source.audio.muted;
    }

    // Audio properties are only valid while the node is tracked (Quickshell docs).
    // The list may contain nulls (verified in source).
    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
