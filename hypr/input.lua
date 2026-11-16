-- Keyboard and touchpad. US QWERTY; Hyprland's own defaults cover mice.
hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "",
        kb_options         = "",
        repeat_rate        = 40,
        repeat_delay       = 250,
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,

        touchpad = {
            natural_scroll       = false,
            clickfinger_behavior = true,
            scroll_factor        = 0.4,
        },
    },

    misc = {
        key_press_enables_dpms   = true,
        mouse_move_enables_dpms  = true,
    },
})
