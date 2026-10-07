{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tuckr
    adwsteamgtk
    wofi
  ];
}
