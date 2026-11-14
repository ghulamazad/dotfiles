pragma Singleton
// Session and power actions, shared by the power menu and the launcher.
//
// Security: Quickshell runs as your ordinary user and never uses sudo or
// pkexec. systemctl suspend/reboot/poweroff are authorized by systemd-logind
// through polkit for the active local session. The command lists are fixed
// constants; nothing user-typed is ever added to them.
import QtQuick
import Quickshell
import qs.themes

Singleton {
    readonly property var actions: [
        // "loginctl lock-session" triggers hypridle's lock_cmd (hypr/hypridle.conf).
        { id: "lock",     name: "Lock",      glyph: Icons.lock,   command: ["loginctl", "lock-session"], confirm: false },
        // Hyprland >= 0.55 dispatches Lua expressions, as in its own example config.
        { id: "logout",   name: "Log out",   glyph: Icons.logout, command: ["hyprctl", "dispatch", "hl.dsp.exit()"], confirm: true },
        { id: "suspend",  name: "Suspend",   glyph: Icons.moon,   command: ["systemctl", "suspend"], confirm: false },
        { id: "reboot",   name: "Reboot",    glyph: Icons.refresh, command: ["systemctl", "reboot"], confirm: true },
        { id: "poweroff", name: "Power off", glyph: Icons.power,  command: ["systemctl", "poweroff"], confirm: true }
    ]

    function run(action) {
        Quickshell.execDetached(action.command);
    }
}
