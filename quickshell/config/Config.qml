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

    // ---- Text and size: change these two, everything else follows ----
    // The font family and the base text size in pixels. Every other size in the
    // shell (bar height, icons, rows, card widths, spacing) is written as
    // Config.px(n), which scales n by fontSize / 12, so the whole interface
    // grows or shrinks together. 12 is the original size; 15 suits a 14-inch
    // 1920x1080 screen at scale 1. Try 14 to 17.
    readonly property string fontFamily: "VictorMono Nerd Font"
    readonly property int fontSize: 17

    readonly property real uiScale: fontSize / 12
    function px(n) { return Math.max(1, Math.round(n * uiScale)); }

    // Derived text sizes, for use as font.pixelSize.
    readonly property int fontSmall: px(10)
    readonly property int fontLarge: px(14)
    readonly property int barHeight: px(26)

    readonly property string terminal: "ghostty"
    // Window class given to the small floating terminals the bar opens
    // (matched by the float rule in hypr/rules.lua).
    readonly property string floatClass: "com.azad.float"
}
