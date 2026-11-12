-- Window and layer rules. Rules are evaluated top to bottom (order matters).
-- Syntax: hl.window_rule({ name = ..., match = { prop = regex }, effect = value })
-- Class regexes use RE2; they are anchored with ^...$ here to be unambiguous.
-- Find a window's class with: hyprctl clients

-- Ignore maximize requests from apps (from the official example config).
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland (from the official example config).
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

-- Small utility windows float, centered, at a sensible size.
hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol|nm-connection-editor|blueman-manager|\\.blueman-manager-wrapped|org\\.gnome\\.Calculator)$" },

    float  = true,
    center = true,
    size   = { 900, 600 },
})

-- File pickers and other portal dialogs float.
hl.window_rule({
    name  = "float-portal-dialogs",
    match = { class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\.desktop\\.gtk|xdg-desktop-portal-kde)$" },

    float  = true,
    center = true,
})

-- Layer rules for Quickshell surfaces. Every Quickshell window sets a
-- WlrLayershell namespace starting with "qs-" so one rule covers all of them.
-- Omarchy uses flat, opaque surfaces with blur disabled (Inventory §3).
hl.layer_rule({
    name  = "qs-surface",
    match = { namespace = "^qs-(bar|panel|launcher|notify|overview|power)$" },

    blur = false,
})

-- The wallpaper is a Quickshell layer surface; never animate or blur it.
hl.layer_rule({
    name  = "qs-wallpaper-no-anim",
    match = { namespace = "^qs-wallpaper$" },

    no_anim = true,
})
