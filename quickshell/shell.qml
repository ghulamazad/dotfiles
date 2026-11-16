//@ pragma UseQApplication
//@ pragma IconTheme Tela-green-dark
// Entry point of the Quickshell shell: wallpaper, top bar, launcher and
// notification popups. Nothing else. Hyprland does all window management; if
// this process crashes, Hyprland keeps running and every non-UI keybinding
// still works. Restart the shell with SUPER+SHIFT+B (bin/restart-shell.sh).
//
// `UseQApplication` is required for the tray's native right-click menus.
// `IconTheme` sets the icons the launcher, tray and notifications use. Tela is
// AUR-only (see README.md); if the folder is missing, Quickshell falls back to
// its default icons.
import Quickshell
import Quickshell.Io
import qs.launcher
import qs.modules
import qs.notifications
import qs.services

ShellRoot {
    Wallpaper {}
    Bar {}
    Launcher {}
    WifiPanel {}
    BluetoothPanel {}
    NotificationPopups {}

    // `qs ipc call <target> <function>` is how the Hyprland keybindings in
    // hypr/bindings.lua reach the shell. These names must match that file.
    IpcHandler {
        target: "launcher"
        function toggle(): void { UIState.toggleLauncher("apps"); }
        function power(): void { UIState.toggleLauncher("power"); }
    }

    IpcHandler {
        target: "bar"
        function toggle(): void { UIState.barVisible = !UIState.barVisible; }
    }
}
