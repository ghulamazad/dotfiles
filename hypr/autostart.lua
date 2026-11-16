-- Autostart. Runs once when Hyprland starts (not on config reload).
-- Every entry here is a background process, so keep the list short.

hl.on("hyprland.start", function()
    -- Export session variables to systemd/D-Bus before launching anything.
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")

    -- The shell: wallpaper, bar, launcher and notifications.
    hl.exec_cmd("qs")

    -- Authentication dialogs for polkit (mounting drives, pkexec, ...).
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")

    -- Lock after 5 minutes, screen off after 10 (hypr/hypridle.conf).
    hl.exec_cmd("hypridle -c " .. (os.getenv("HOME") or "") .. "/.config/hypr/hypridle.conf")

    -- Dark mode and icon theme for GTK apps. Needs the session D-Bus, so it is
    -- applied here as well as by install-config.sh.
    hl.exec_cmd((os.getenv("HOME") or "") .. "/.local/scripts/dark-theme.sh")
end)
