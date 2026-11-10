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
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/dotfiles"
    // install.sh links the repo's scripts/ here (see packages/links.txt).
    readonly property string scriptsDir: home + "/.local/share/dotfiles/scripts"
    readonly property string wallpaperDir: Quickshell.env("DOTFILES_WALLPAPER_DIR") || (home + "/Pictures/Wallpapers")

    readonly property int barHeight: 34
    readonly property int radius: 12
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property string terminal: "ghostty"
}
