-- Look and feel: a flat layout (gaps 5/10, 2 px borders, square corners, no
-- blur, no shadow) in the Petrol Lagoon colours, with short window animations.
-- To switch every animation off, set animations.enabled = false below.
-- Reference: https://wiki.hypr.land/Configuring/Variables/

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 2,
        border_size = 1,

        col = {
            active_border   = { colors = { "rgba(35d0c0ee)", "rgba(6cc48eee)" }, angle = 45 },
            inactive_border = "rgba(2a3f42cc)",
        },

        resize_on_border        = true,
        extend_border_grab_area = 8,
        hover_icon_on_border    = true,
        allow_tearing           = false,
        layout                  = "dwindle",
    },

    decoration = {
        rounding = 0,
        shadow   = { enabled = false },
        blur     = { enabled = false },
    },

    group = {
        col = {
            border_active   = { colors = { "rgba(35d0c0ee)", "rgba(6cc48eee)" }, angle = 45 },
            border_inactive = "rgba(2a3f42cc)",
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },

    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        background_color           = "rgb(0c1618)",
        disable_scale_notification = true,
        focus_on_activate          = true,
        initial_workspace_tracking = 0,
        -- Lets a restarted shell recover the lock screen if hyprlock died.
        allow_session_lock_restore = true,
    },

    cursor = {
        hide_on_key_press        = true,
        warp_on_change_workspace = 1,
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("linear",       { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",        { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 3.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch",    enabled = false })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false })
