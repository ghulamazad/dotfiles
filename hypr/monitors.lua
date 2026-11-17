-- Monitors. See https://wiki.hypr.land/configuring/core/monitors/
--
-- hl.monitor({
--     output = "DP-1",
--     mode = "preferred",
--     position = "auto",
--     scale = 1,
-- })

hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "1920x0",
    scale    = 1,
})

-- GTK applications: 1x scaling for 1080p
hl.env("GDK_SCALE", "1")