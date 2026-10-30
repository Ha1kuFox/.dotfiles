local handle = io.popen("hostname")
local hostname = handle:read("*l"):lower()
handle:close()

if hostname == "haikyo" then
    hl.monitor({
        output    = "HDMI-A-1",
        mode      = "highres",
        position  = "auto-center-left",
        scale     = "1",
        transform = 3
    })
    hl.monitor({
        output   = "DP-2",
        mode     = "highres",
        position = "auto-center-right",
        scale    = "1",
    })
else
    hl.monitor({
        output   = "",
        mode     = "highres",
        position = "auto",
        scale    = "1",
    })
end