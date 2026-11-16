-- Window rules. Syntax: hl.window_rule({ name = ..., match = { prop = regex }, effect = value })
-- Find a window's class with: hyprctl clients

-- Ignore maximize requests from apps.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Watching a fullscreen video or presentation must not trigger the idle lock.
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },

    idle_inhibit = "fullscreen",
})

-- Any terminal started with --class=com.azad.float (a small tool you launch by
-- hand) floats in the middle of the screen. The class comes from config/Config.qml.
hl.window_rule({
    name  = "azad-floating-tools",
    match = { class = "^com\\.azad\\.float$" },

    float  = true,
    center = true,
    size   = { 900, 600 },
})
