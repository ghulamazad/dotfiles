//@ pragma UseQApplication
// Entry point of the Quickshell shell: a bar, an app launcher and notification
// popups. Nothing else. Quickshell draws UI only; Hyprland does all window
// management, so if this process crashes every keybinding still works.
// Restart it with SUPER+SHIFT+B (scripts/restart-shell.sh).
//
// `UseQApplication` is required for the tray's native right-click menus.
import Quickshell
import qs.launcher
import qs.modules
import qs.notifications
import qs.services

ShellRoot {
    Wallpaper {}
    Bar {}
    Launcher {}
    NotificationPopups {}

    // `qs ipc call launcher toggle` is how SUPER+Space (hypr/keybindings.lua)
    // reaches the shell.
    IpcHandler {
        target: "launcher"
        function toggle(): void { UIState.toggleLauncher(); }
    }
}
