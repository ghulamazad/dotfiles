-- Environment variables for everything Hyprland launches.
-- Only set what is needed; Hyprland already exports the Wayland session vars.

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Prefer Wayland for Qt apps (including Quickshell), fall back to X11.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
