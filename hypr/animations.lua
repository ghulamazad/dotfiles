-- Animations. Syntax taken from the official example config:
--   hl.curve(name, { type = "bezier", points = { {x1, y1}, {x2, y2} } })
--   hl.animation({ leaf = ..., enabled = ..., speed = ..., bezier = ..., style = ... })
-- Lower speed = faster animation. Tasteful rather than flashy.

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.4,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.6,  bezier = "linear",       style = "popin 90%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.7,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,    bezier = "quick" })
-- Layers = Quickshell panels, launcher, notifications.
hl.animation({ leaf = "layers",        enabled = true, speed = 3.8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slide" })
