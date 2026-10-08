hl.on("hyprland.start", function ()
  hl.exec_cmd("noctalia")
  hl.exec_cmd("/run/current-system/sw/libexec/polkit-kde-authentication-agent-1")
end)
