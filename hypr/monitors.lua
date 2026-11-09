-- Monitors. See https://wiki.hypr.land/configuring/core/monitors/
--
-- The empty output name is a catch-all: every monitor gets its preferred mode
-- and is placed automatically to the right of the previous one. This works
-- for a VM and for plug-and-play multi-monitor use without edits.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Example for pinning a specific layout (find names with `hyprctl monitors`).
-- Uncomment and adapt; named rules take effect alongside the catch-all.
--
-- hl.monitor({ output = "eDP-1",   mode = "1920x1080@60", position = "0x0",    scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred",    position = "1920x0", scale = 1 })
