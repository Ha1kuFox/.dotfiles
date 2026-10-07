{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./modules.nix
  ];
  system.stateVersion = "25.05";
  environment.variables.GSK_RENDERER = "ngl";
  environment.systemPackages = with pkgs; [
    ayugram-desktop
    yandex-music
  ];
}
