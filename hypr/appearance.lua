-- Look and feel. Option names follow the official example config shipped with
-- Hyprland (example/hyprland.lua) and https://wiki.hypr.land/configuring/core/config-options/

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 10,
        border_size = 2,

        col = {
            -- Accent gradient on the focused window, muted grey otherwise.
            active_border   = { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 },
            inactive_border = "rgba(3b4252aa)",
        },

        -- Drag borders/gaps with the mouse to resize.
        resize_on_border = true,

        -- Tearing is a gaming feature with tradeoffs; leave it off.
        allow_tearing = false,

        -- Default layout. Toggle at runtime with SUPER+SHIFT+SPACE.
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee0b0d12,
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,    -- no mascot wallpapers; Quickshell draws the wallpaper
        disable_hyprland_logo   = true,
    },
})

-- Dwindle: binary-tree tiling. preserve_split keeps split direction stable
-- when windows close.
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- Master: one large window plus a stack. New windows join the stack.
hl.config({
    master = {
        new_status = "slave",
    },
})
