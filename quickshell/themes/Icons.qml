pragma Singleton
// Material Design icons from Nerd Fonts 3 (the "md" set, U+F0001 and up).
// They render only if a Nerd Font is active: packages.txt installs
// ttf-victor-mono-nerd. Without it you will see empty boxes.
//
// The codepoints are above U+FFFF, so QML strings need surrogate pairs. They are
// written as escapes so the file survives copy and paste. Codepoints come from
// the Material Design Icons 7.4 stylesheet; the trailing name is the icon name
// to search for in the Nerd Fonts cheat sheet.
import QtQuick
import Quickshell

Singleton {
    readonly property string arch:               "\uDB82\uDCC7"   // arch
    readonly property string wifi:               "\uDB82\uDD28"   // wifi-strength-4
    readonly property string wifiOff:            "\uDB82\uDD2D"   // wifi-strength-off
    readonly property string wired:              "\uDB80\uDE00"   // ethernet
    readonly property string bluetooth:          "\uDB80\uDCAF"   // bluetooth
    readonly property string bluetoothConnected: "\uDB80\uDCB1"   // bluetooth-connect
    readonly property string bluetoothOff:       "\uDB80\uDCB2"   // bluetooth-off
    readonly property string volumeHigh:         "\uDB81\uDD7E"   // volume-high
    readonly property string volumeMedium:       "\uDB81\uDD80"   // volume-medium
    readonly property string volumeLow:          "\uDB81\uDD7F"   // volume-low
    readonly property string volumeMuted:        "\uDB81\uDF5F"   // volume-mute
    readonly property string batteryFull:        "\uDB80\uDC79"   // battery
    readonly property string battery90:          "\uDB80\uDC82"   // battery-90
    readonly property string battery70:          "\uDB80\uDC80"   // battery-70
    readonly property string battery50:          "\uDB80\uDC7E"   // battery-50
    readonly property string battery30:          "\uDB80\uDC7C"   // battery-30
    readonly property string battery10:          "\uDB80\uDC7A"   // battery-10
    readonly property string batteryCharging:    "\uDB80\uDC84"   // battery-charging
    readonly property string batteryAlert:       "\uDB80\uDC83"   // battery-alert
    readonly property string power:              "\uDB81\uDC25"   // power
    readonly property string moon:               "\uDB82\uDD04"   // power-sleep
    readonly property string lock:               "\uDB80\uDF3E"   // lock
    readonly property string lockClosed:         "\uDB80\uDF3E"   // lock (secured networks)
    readonly property string logout:             "\uDB80\uDF43"   // logout
    readonly property string refresh:            "\uDB81\uDF09"   // restart
    readonly property string cpu:                "\uDB81\uDE1A"   // chip
    readonly property string search:             "\uDB80\uDF49"   // magnify
    readonly property string close:              "\uDB80\uDD56"   // close

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
