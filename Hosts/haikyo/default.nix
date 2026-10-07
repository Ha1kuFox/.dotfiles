{
  inputs,
  pkgs,
  ...
}: {
  networking.hostName = "haikyo";
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
  imports = [
    ./hardware.nix
  ];
  programs.xppen.enable = true;
  programs.xppen.package = pkgs.callPackage ../../Packages/xppen4 {};
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
