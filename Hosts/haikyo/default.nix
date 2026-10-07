{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./modules.nix
  ];
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
  programs.xppen = {
    enable = true;
    package = pkgs.callPackage ../../Packages/xppen4 {};
  };
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
