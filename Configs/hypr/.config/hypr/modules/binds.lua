local v = require("modules.vars")

local ipc = "noctalia msg "

hl.bind(v.mainMod .. " + T", hl.dsp.exec_cmd(v.terminal))
hl.bind(v.mainMod .. " + C", hl.dsp.window.close())
-- hl.bind(v.mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- hl.bind(v.mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("quickshell ipc call colorpicker pick"))
hl.bind(v.mainMod .. " + E", hl.dsp.exec_cmd(v.fileManager))
hl.bind(v.mainMod .. " + B", hl.dsp.exec_cmd(v.browser))
hl.bind(v.mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(v.mainMod .. " + SPACE", hl.dsp.exec_cmd("/home/user/projects/mofu/target/debug/mofu --toggle-launcher"))
hl.bind(v.mainMod .. " + SPACE", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(v.mainMod .. " + O", hl.dsp.exec_cmd("/home/user/projects/mofu/target/debug/mofu --toggle-power"))
hl.bind(v.mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/user/projects/mofu/target/debug/mofu --toggle-settings"))
hl.bind(v.mainMod .. " + F3", hl.dsp.exec_cmd("/home/user/projects/mofu/target/debug/mofu --debug-ui"))
hl.bind(v.mainMod .. " + P", hl.dsp.exec_cmd("quickshell ipc call command toggle"))
hl.bind(v.mainMod .. " + ALT + P", hl.dsp.window.pseudo())
hl.bind(v.mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(v.mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(v.mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(v.mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(v.mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Focus
hl.bind(v.mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(v.mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(v.mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(v.mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(v.mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(v.mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Screen translator
hl.bind(v.mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("quickshell ipc call screenTranslator translate"))

-- PawDB knowledge base (fullscreen blur overlay)
hl.bind(v.mainMod .. " + TAB", hl.dsp.exec_cmd("quickshell ipc call mofuko-db toggle"))

-- Mofuko component demo
hl.bind(v.mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("quickshell ipc call mofuko-demo toggle"))

-- Screenshot
hl.bind(v.mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"), { locked = true })

-- Scroll workspaces
hl.bind(v.mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(v.mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse drag/resize
hl.bind(v.mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(v.mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize window in all directions
hl.bind(v.mainMod .. " + equal", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.window.resize({x=10, y=10, relative=true})'; hyprctl dispatch 'hl.dsp.window.move({x=-5, y=-5, relative=true})'"), { repeating = true, description = "grow window" })
hl.bind(v.mainMod .. " + minus", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.window.resize({x=-10, y=-10, relative=true})'; hyprctl dispatch 'hl.dsp.window.move({x=5, y=5, relative=true})'"), { repeating = true, description = "shrink window" })

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"), { locked = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
