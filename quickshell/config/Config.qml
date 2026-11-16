pragma Singleton
// User-tunable settings. Edit and save: Quickshell reloads the shell itself.
//
// Scanner rule (verified in Quickshell's source): the line above must be
// exactly `pragma Singleton`, and imports must come before the first line
// that contains an opening brace. Keep braces out of header comments.
import QtQuick
import Quickshell

Singleton {
    readonly property string home: Quickshell.env("HOME") || ""

    // Wallpaper shown behind the windows (also set in hypr/hyprlock.conf).
    readonly property string wallpaper: home + "/Pictures/wallpapers/tanjiro-nezuko.jpg"

    readonly property string scriptsDir: home + "/.local/scripts"

    readonly property int radius: 0       // square corners, as in hypr/looknfeel.lua
    readonly property int barHeight: 26
    readonly property string fontFamily: "VictorMono Nerd Font"
    readonly property int fontSize: 12
    readonly property string terminal: "ghostty"
    // Window class given to the small floating terminals the bar opens
    // (matched by the float rule in hypr/rules.lua).
    readonly property string floatClass: "com.azad.float"
}
