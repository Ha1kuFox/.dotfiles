{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wl-screenrec
  ];
}
