-- Input. Option names from the official example config.

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        repeat_rate  = 35,
        repeat_delay = 250,

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Three-finger horizontal swipe switches workspaces (touchpads only).
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
