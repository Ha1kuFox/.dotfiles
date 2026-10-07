-- Suppress maximize
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Make some windows float and follow
hl.window_rule({
  name = "float-and-follow",
  match = { title = "^(Picture-in-Picture|Picture in picture)$" }, 
  float = true,
  pin = true
})

-- Fix XWayland drags
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

-- No-anim overlay
hl.layer_rule({
    name  = "no-anim-overlay",
    match = { namespace = "^my-overlay$" },
    no_anim = true,
})
