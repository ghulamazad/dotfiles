pragma Singleton
// Glyphs from the Font Awesome range of Nerd Fonts (U+F000 to U+F2E0).
// They render only if a Nerd Font is active: packages.txt installs
// ttf-jetbrains-mono-nerd. Without it you will see empty boxes.
import QtQuick
import Quickshell

Singleton {
    readonly property string apps: ""
    readonly property string wifi: ""
    readonly property string wired: ""
    readonly property string bluetooth: ""
    readonly property string volumeHigh: ""
    readonly property string volumeLow: ""
    readonly property string volumeOff: ""
    readonly property string mic: ""
    readonly property string micOff: ""
    readonly property string batteryFull: ""
    readonly property string batteryThreeQuarters: ""
    readonly property string batteryHalf: ""
    readonly property string batteryQuarter: ""
    readonly property string batteryEmpty: ""
    readonly property string bolt: ""
    readonly property string power: ""
    readonly property string bell: ""
    readonly property string bellOff: ""
    readonly property string sun: ""
    readonly property string moon: ""
    readonly property string lock: ""
    readonly property string logout: ""
    readonly property string refresh: ""
    readonly property string clipboard: ""
    readonly property string image: ""
    readonly property string calendar: ""
    readonly property string cpu: ""
    readonly property string thermometer: ""
    readonly property string search: ""
    readonly property string trash: ""
    readonly property string close: ""
    readonly property string desktop: ""
    readonly property string lockClosed: ""
    readonly property string check: ""
    readonly property string camera: ""

    function battery(fraction) {
        if (fraction > 0.875) return batteryFull;
        if (fraction > 0.625) return batteryThreeQuarters;
        if (fraction > 0.375) return batteryHalf;
        if (fraction > 0.125) return batteryQuarter;
        return batteryEmpty;
    }
}
