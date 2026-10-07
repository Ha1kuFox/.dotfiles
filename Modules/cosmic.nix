{
  services = {
    # Не уверен, но согласно вики повышает производительность
    system76-scheduler.enable = true;
    displayManager = {
      cosmic-greeter.enable = true;
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
    desktopManager.cosmic.enable = true;
  };
}
