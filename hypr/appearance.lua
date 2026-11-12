-- Look and feel matching Omarchy compositor settings (Inventory §3).
-- Reference: https://wiki.hypr.land/Configuring/Variables/

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 1,
        border_size = 2,

        col = {
            -- Tokyo Night accent border on focused window, muted grey otherwise
            active_border   = "rgba(7aa2f7ee)",
            inactive_border = "rgba(595959aa)",
        },

        -- Drag borders/gaps with the mouse to resize
        resize_on_border        = true,
        extend_border_grab_area = 8,
        hover_icon_on_border    = true,

        -- Tearing is a gaming feature with tradeoffs; leave it off
        allow_tearing = false,

        -- Default layout
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    cursor = {
        hide_on_key_press        = true,
        warp_on_change_workspace = 1,
    },

    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        background_color           = "rgb(000000)",
        focus_on_activate          = true,
        initial_workspace_tracking = 0,
        allow_session_lock_restore = true,
    },
})

-- Dwindle: binary-tree tiling. preserve_split keeps split direction stable.
hl.config({
    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },
})

-- Master layout fallback
hl.config({
    master = {
        new_status = "slave",
    },
})
