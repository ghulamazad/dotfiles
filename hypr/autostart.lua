-- Autostart. Runs once when Hyprland starts (not on config reload).
-- Keep this list short: every entry is a background process.

hl.on("hyprland.start", function()
    -- Quickshell: the whole desktop UI (bar, launcher, notification popups, wallpaper).
    -- If it crashes, Hyprland keeps working; SUPER+SHIFT+B restarts it.
    hl.exec_cmd("qs")

    -- Polkit authentication agent so GUI apps can ask for privileges safely.
    -- QML never runs privileged commands; polkit prompts come from this agent.
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")

    -- Idle management: lock after inactivity, lock before suspend.
    hl.exec_cmd("hypridle")

    -- Dark preference for GTK/portal apps. Needs the session D-Bus, so it is
    -- (re)applied here as well as by install.sh (which may run on a TTY).
    hl.exec_cmd(os.getenv("HOME") .. "/.local/share/dotfiles/scripts/dark-theme.sh")
end)
