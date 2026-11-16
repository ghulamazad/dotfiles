pragma Singleton
// Material Design icons from Nerd Fonts 3 (the "md" set, U+F0001 and up).
// They render only if a Nerd Font is active: packages.txt installs
// ttf-victor-mono-nerd. Without it you will see empty boxes.
//
// Each icon below is the actual glyph character (a private-use character, so
// it looks like an empty box in editors without a Nerd Font). The trailing name is
// the icon to search for in the Nerd Fonts cheat sheet, to swap one for another.
import QtQuick
import Quickshell

Singleton {
    readonly property string chevronDown:        "󰅀"   // chevron-down
    readonly property string chevronUp:          "󰅃"   // chevron-up
    readonly property string chevronLeft:        "󰅁"   // chevron-left
    readonly property string chevronRight:       "󰅂"   // chevron-right
    readonly property string memory:             "󰍛"   // memory
    readonly property string speaker:            "󰓃"   // speaker
    readonly property string headphones:         "󰋋"   // headphones
    readonly property string leaf:               "󰌪"   // leaf
    readonly property string speedometer:        "󰓅"   // speedometer
    readonly property string bolt:               "󱐋"   // lightning-bolt
    readonly property string dots:               "󰇘"   // dots-horizontal
    readonly property string check:              "󰄬"   // check
    readonly property string arch:               "󰣇"   // arch
    readonly property string wifi:               "󰤨"   // wifi-strength-4
    readonly property string wifiOff:            "󰤭"   // wifi-strength-off
    readonly property string wired:              "󰈀"   // ethernet
    readonly property string bluetooth:          "󰂯"   // bluetooth
    readonly property string bluetoothConnected: "󰂱"   // bluetooth-connect
    readonly property string bluetoothOff:       "󰂲"   // bluetooth-off
    readonly property string volumeHigh:         "󰕾"   // volume-high
    readonly property string volumeMedium:       "󰖀"   // volume-medium
    readonly property string volumeLow:          "󰕿"   // volume-low
    readonly property string volumeMuted:        "󰝟"   // volume-mute
    readonly property string batteryFull:        "󰁹"   // battery
    readonly property string battery90:          "󰂂"   // battery-90
    readonly property string battery70:          "󰂀"   // battery-70
    readonly property string battery50:          "󰁾"   // battery-50
    readonly property string battery30:          "󰁼"   // battery-30
    readonly property string battery10:          "󰁺"   // battery-10
    readonly property string batteryCharging:    "󰂄"   // battery-charging
    readonly property string batteryAlert:       "󰂃"   // battery-alert
    readonly property string power:              "󰐥"   // power
    readonly property string moon:               "󰤄"   // power-sleep
    readonly property string lock:               "󰌾"   // lock
    readonly property string lockClosed:         "󰌾"   // lock (secured networks)
    readonly property string logout:             "󰍃"   // logout
    readonly property string refresh:            "󰜉"   // restart
    readonly property string cpu:                "󰘚"   // chip
    readonly property string search:             "󰍉"   // magnify
    readonly property string close:              "󰅖"   // close

    function battery(fraction) {
        if (fraction > 0.95) return batteryFull;
        if (fraction > 0.80) return battery90;
        if (fraction > 0.60) return battery70;
        if (fraction > 0.40) return battery50;
        if (fraction > 0.20) return battery30;
        return battery10;
    }

    function volume(level) {
        if (level < 0.34) return volumeLow;
        if (level < 0.67) return volumeMedium;
        return volumeHigh;
    }
}
