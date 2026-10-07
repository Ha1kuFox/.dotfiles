{pkgs, ...}: {
  environment.systemPackages = with pkgs; [hyprshot wl-clipboard];
}
