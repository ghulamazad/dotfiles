-- Autostart. Runs once when Hyprland starts (not on config reload).
-- Keep this list short: every entry is a background process.

hl.on("hyprland.start", function()
    -- Quickshell: the whole desktop UI (bar, launcher, notifications, wallpaper).
    -- If it crashes, Hyprland keeps working; SUPER+SHIFT+B restarts it.
    hl.exec_cmd("qs")

    -- Polkit authentication agent so GUI apps can ask for privileges safely.
    -- QML never runs privileged commands; polkit prompts come from this agent.
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")

    -- Idle management: lock after inactivity, lock before suspend.
    hl.exec_cmd("hypridle")

    -- Dark preference for GTK/portal apps. Needs the session D-Bus, so it is
    -- (re)applied here as well as by install-config.sh (which may run on a TTY).
    hl.exec_cmd(os.getenv("HOME") .. "/.local/scripts/dark-theme.sh")

    -- Clipboard history database (read by the Quickshell launcher).
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
