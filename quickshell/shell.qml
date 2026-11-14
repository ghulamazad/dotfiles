//@ pragma UseQApplication
// Entry point of the Quickshell desktop shell. Quickshell draws the UI only;
// Hyprland does all window management. If this process crashes, Hyprland keeps
// running and every non-UI keybinding still works. Restart the shell with
// SUPER+SHIFT+B (scripts/restart-shell.sh).
//
// `UseQApplication` is required for the tray's native right-click menus.
//
// Each module below is independent: it reads shared state from qs.services and
// never imports another module. Comment one out to disable it.
import Quickshell
import Quickshell.Io
import qs.launcher
import qs.modules
import qs.notifications
import qs.panels
import qs.services

ShellRoot {
    Wallpaper {}
    Bar {}
    Launcher {}
    CalendarPanel {}
    WifiPanel {}
    BluetoothPanel {}
    AudioPanel {}
    MonitorPanel {}
    BatteryPanel {}
    NotificationPopups {}
    NotificationCenter {}
    PowerMenu {}

    // `qs ipc call <target> <function>` is how the Hyprland keybindings in
    // hypr/keybindings.lua reach the shell. These names must match that file.
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (UIState.launcher) UIState.closeAll();
            else UIState.openLauncher("apps");
        }
        function openClipboard(): void { UIState.openLauncher("clipboard"); }
        function openWallpapers(): void { UIState.openLauncher("wallpapers"); }
    }

    IpcHandler {
        target: "notifications"
        function toggleCenter(): void { UIState.toggle("notificationCenter"); }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { UIState.toggle("power"); }
    }
}
